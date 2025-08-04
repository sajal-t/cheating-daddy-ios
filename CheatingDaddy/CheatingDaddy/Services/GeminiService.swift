import Foundation
import Combine

class GeminiService: ObservableObject {
    @Published var isConnected = false
    @Published var currentResponse = ""
    @Published var isProcessing = false
    
    private var apiKey: String = ""
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession
    private var currentProfile: SessionType = .interview
    private var customPrompt: String = ""
    private var conversationHistory: [(transcription: String, aiResponse: String)] = []
    
    // Callbacks
    var onResponseReceived: ((String) -> Void)?
    var onError: ((Error) -> Void)?
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.urlSession = URLSession(configuration: config)
    }
    
    func configure(apiKey: String, profile: SessionType, customPrompt: String = "") {
        self.apiKey = apiKey
        self.currentProfile = profile
        self.customPrompt = customPrompt
    }
    
    func startSession() async throws {
        guard !apiKey.isEmpty else {
            throw GeminiError.missingAPIKey
        }
        
        try await connectToGemini()
    }
    
    private func connectToGemini() async throws {
        // For Gemini API, we'll use HTTP requests instead of WebSocket
        // as the real-time API might not be available in all regions
        DispatchQueue.main.async {
            self.isConnected = true
        }
        print("Connected to Gemini API")
    }
    
    func sendTranscription(_ text: String) async {
        guard isConnected, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        DispatchQueue.main.async {
            self.isProcessing = true
        }
        
        do {
            let response = await generateResponse(for: text)
            
            DispatchQueue.main.async {
                self.currentResponse = response
                self.isProcessing = false
                self.onResponseReceived?(response)
            }
            
            // Save conversation turn
            conversationHistory.append((transcription: text, aiResponse: response))
            
        } catch {
            DispatchQueue.main.async {
                self.isProcessing = false
                self.onError?(error)
            }
        }
    }
    
    func sendChatMessage(_ message: String) async -> String {
        guard isConnected else { return "Not connected to AI service" }
        
        DispatchQueue.main.async {
            self.isProcessing = true
        }
        
        let response = await generateResponse(for: message, isChat: true)
        
        DispatchQueue.main.async {
            self.isProcessing = false
        }
        
        return response
    }
    
    private func generateResponse(for input: String, isChat: Bool = false) async -> String {
        do {
            let systemPrompt = getSystemPrompt()
            let contextualInput = buildContextualInput(input, isChat: isChat)
            
            let requestBody = GeminiRequest(
                contents: [
                    GeminiContent(
                        parts: [
                            GeminiPart(text: systemPrompt),
                            GeminiPart(text: contextualInput)
                        ]
                    )
                ],
                generationConfig: GeminiGenerationConfig(
                    temperature: 0.7,
                    topK: 40,
                    topP: 0.95,
                    maxOutputTokens: 1024
                )
            )
            
            let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=\(apiKey)")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(requestBody)
            
            let (data, response) = try await urlSession.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Gemini API Response Status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    return "Error: Unable to get AI response"
                }
            }
            
            let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
            
            if let candidate = geminiResponse.candidates.first,
               let part = candidate.content.parts.first {
                return part.text
            }
            
            return "No response generated"
            
        } catch {
            print("Error generating response: \(error)")
            return "Error: \(error.localizedDescription)"
        }
    }
    
    private func getSystemPrompt() -> String {
        let profilePrompts: [SessionType: String] = [
            .interview: """
                You are an AI-powered interview assistant, designed to act as a discreet on-screen teleprompter. Your mission is to help the user excel in their job interview by providing concise, impactful, and ready-to-speak answers or key talking points.
                
                **RESPONSE FORMAT REQUIREMENTS:**
                - Keep responses SHORT and CONCISE (1-3 sentences max)
                - Use **markdown formatting** for better readability
                - Use **bold** for key points and emphasis
                - Focus on the most essential information only
                
                Provide only the exact words to say in **markdown format**. No coaching, no "you should" statements, no explanations - just the direct response the candidate can speak immediately. Keep it **short and impactful**.
                """,
            
            .sales: """
                You are a sales call assistant. Your job is to provide the exact words the salesperson should say to prospects during sales calls. Give direct, ready-to-speak responses that are persuasive and professional.
                
                **RESPONSE FORMAT REQUIREMENTS:**
                - Keep responses SHORT and CONCISE (1-3 sentences max)
                - Use **markdown formatting** for better readability
                - Use **bold** for key points and emphasis
                - Focus on the most essential information only
                
                Provide only the exact words to say in **markdown format**. Be persuasive but not pushy. Focus on value and addressing objections directly. Keep responses **short and impactful**.
                """,
            
            .meeting: """
                You are a meeting assistant designed to help participants stay focused and contribute meaningfully to discussions.
                
                **RESPONSE FORMAT REQUIREMENTS:**
                - Keep responses SHORT and CONCISE (1-3 sentences max)
                - Use **markdown formatting** for better readability
                - Use **bold** for key points and emphasis
                - Focus on the most essential information only
                
                Provide direct, actionable suggestions for meeting participation. Keep responses **short and to the point**.
                """,
            
            .negotiation: """
                You are a negotiation assistant providing strategic guidance for achieving win-win outcomes.
                
                **RESPONSE FORMAT REQUIREMENTS:**
                - Keep responses SHORT and CONCISE (1-3 sentences max)
                - Use **markdown formatting** for better readability
                - Use **bold** for key points and emphasis
                - Focus on the most essential information only
                
                Provide only the exact words to say in **markdown format**. Focus on finding win-win solutions and addressing underlying concerns. Keep responses **short and impactful**.
                """,
            
            .exam: """
                You are an exam assistant designed to help students pass tests efficiently. Your role is to provide direct, accurate answers to exam questions with minimal explanation.
                
                **RESPONSE FORMAT REQUIREMENTS:**
                - Keep responses SHORT and CONCISE (1-2 sentences max)
                - Use **markdown formatting** for better readability
                - Use **bold** for the answer choice/result
                - Focus on the most essential information only
                
                Provide direct exam answers in **markdown format**. Include the question text, the correct answer choice, and a brief justification. Focus on efficiency and accuracy. Keep responses **short and to the point**.
                """
        ]
        
        let basePrompt = profilePrompts[currentProfile] ?? profilePrompts[.interview]!
        
        if !customPrompt.isEmpty {
            return basePrompt + "\n\nUser-provided context:\n-----\n\(customPrompt)\n-----\n"
        }
        
        return basePrompt
    }
    
    private func buildContextualInput(_ input: String, isChat: Bool) -> String {
        if isChat {
            return input
        }
        
        // For transcription, add context if available
        let context = getConversationContext()
        if !context.isEmpty {
            return "\(context)\n\nCurrent question/statement: \(input)"
        }
        
        return "Current question/statement: \(input)"
    }
    
    private func getConversationContext() -> String {
        guard !conversationHistory.isEmpty else { return "" }
        
        let recentHistory = Array(conversationHistory.suffix(3)) // Last 3 exchanges
        let transcriptions = recentHistory
            .map { $0.transcription }
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        if transcriptions.isEmpty { return "" }
        
        return "Previous conversation context:\n" + transcriptions.joined(separator: "\n")
    }
    
    func disconnect() {
        webSocketTask?.cancel()
        webSocketTask = nil
        conversationHistory.removeAll()
        
        DispatchQueue.main.async {
            self.isConnected = false
            self.currentResponse = ""
            self.isProcessing = false
        }
        
        print("Disconnected from Gemini API")
    }
    
    deinit {
        disconnect()
    }
}

// MARK: - Gemini API Models
struct GeminiRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiGenerationConfig: Codable {
    let temperature: Double
    let topK: Int
    let topP: Double
    let maxOutputTokens: Int
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]
}

struct GeminiCandidate: Codable {
    let content: GeminiContent
}

// MARK: - Errors
enum GeminiError: Error, LocalizedError {
    case missingAPIKey
    case connectionFailed
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Gemini API key is required"
        case .connectionFailed:
            return "Failed to connect to Gemini API"
        case .invalidResponse:
            return "Invalid response from Gemini API"
        }
    }
}
