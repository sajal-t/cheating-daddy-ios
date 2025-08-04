import Foundation

enum MessageSender: String, Codable {
    case user = "user"
    case ai = "ai"
    case system = "system"
}

struct Message: Identifiable, Codable {
    let id: UUID
    let content: String
    let sender: MessageSender
    let timestamp: Date
    var isTyping: Bool = false
    
    init(content: String, sender: MessageSender) {
        self.id = UUID()
        self.content = content
        self.sender = sender
        self.timestamp = Date()
    }
    
    init(content: String, sender: MessageSender, isTyping: Bool) {
        self.id = UUID()
        self.content = content
        self.sender = sender
        self.timestamp = Date()
        self.isTyping = isTyping
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: timestamp)
    }
}

// MARK: - Conversation Management
class ConversationManager: ObservableObject {
    @Published var messages: [Message] = []
    @Published var currentTranscription: String = ""
    @Published var isAITyping: Bool = false
    
    private var sessionId: String?
    private var conversationHistory: [(transcription: String, aiResponse: String)] = []
    
    func startNewSession() {
        sessionId = UUID().uuidString
        messages.removeAll()
        conversationHistory.removeAll()
        currentTranscription = ""
        print("New conversation session started: \(sessionId ?? "unknown")")
    }
    
    func addMessage(_ message: Message) {
        DispatchQueue.main.async {
            self.messages.append(message)
        }
    }
    
    func updateTranscription(_ text: String) {
        DispatchQueue.main.async {
            self.currentTranscription = text
        }
    }
    
    func saveConversationTurn(transcription: String, aiResponse: String) {
        let turn = (transcription: transcription.trimmingCharacters(in: .whitespacesAndNewlines),
                   aiResponse: aiResponse.trimmingCharacters(in: .whitespacesAndNewlines))
        
        conversationHistory.append(turn)
        print("Saved conversation turn: \(turn)")
    }
    
    func getConversationContext() -> String {
        guard !conversationHistory.isEmpty else { return "" }
        
        let transcriptions = conversationHistory
            .map { $0.transcription }
            .filter { !$0.isEmpty }
        
        if transcriptions.isEmpty { return "" }
        
        return "Previous conversation context:\n\n" + transcriptions.joined(separator: "\n")
    }
    
    func setAITyping(_ typing: Bool) {
        DispatchQueue.main.async {
            self.isAITyping = typing
        }
    }
}
