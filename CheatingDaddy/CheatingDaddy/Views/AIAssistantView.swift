import SwiftUI

struct AIAssistantView: View {
    let sessionType: SessionType
    let onBack: () -> Void
    
    @StateObject private var audioService = AudioService()
    @StateObject private var geminiService = GeminiService()
    @StateObject private var conversationManager = ConversationManager()
    
    @State private var showingChat = false
    @State private var currentGuidance = "Ready to provide real-time guidance"
    @State private var showingSettings = false
    @State private var apiKey = ""
    @State private var customPrompt = ""
    @State private var showingPermissionAlert = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.black,
                    Color.black.opacity(0.9),
                    Color.purple.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Background effects
            Circle()
                .fill(Color.purple.opacity(0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -150, y: -300)
            
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: 150, y: 300)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text(sessionType.displayName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(audioService.isRecording ? "Listening..." : "Tap to start")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // Main content
                VStack(spacing: 32) {
                    // Status text
                    Text(audioService.isRecording ? "Listening and analyzing..." : "Ready to provide real-time guidance")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    // Sound wave visualization
                    SoundWaveView(isActive: audioService.isRecording, audioLevel: audioService.audioLevel)
                        .frame(height: 200)
                        .padding(.horizontal, 32)
                    
                    // AI Guidance Display
                    VStack(spacing: 16) {
                        Text("AI-Powered Real-time Guidance")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("for Live Conversations")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))
                        
                        // Guidance text area
                        ScrollView {
                            Text(currentGuidance)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                        }
                        .frame(maxHeight: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Control buttons
                HStack(spacing: 24) {
                    // Chat button
                    Button(action: { showingChat = true }) {
                        Image(systemName: "message.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(showingChat ? .white : .white.opacity(0.9))
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(showingChat ? Color.purple : Color.white.opacity(0.1))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    
                    // Main recording button
                    Button(action: toggleRecording) {
                        Image(systemName: audioService.isRecording ? "mic.slash.fill" : "mic.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(
                                Circle()
                                    .fill(audioService.isRecording ? Color.red : Color.white.opacity(0.1))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                    )
                            )
                            .scaleEffect(audioService.isRecording ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: audioService.isRecording)
                    }
                    
                    // End session button
                    Button(action: onBack) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.9))
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                }
                .padding(.bottom, 50)
            }
            
            // Chat panel overlay
            if showingChat {
                ChatPanelView(
                    isShowing: $showingChat,
                    conversationManager: conversationManager,
                    geminiService: geminiService
                )
                .transition(.move(edge: .trailing))
                .animation(.easeInOut(duration: 0.3), value: showingChat)
            }
        }
        .onAppear {
            setupServices()
        }
        .onDisappear {
            audioService.stopRecording()
            geminiService.disconnect()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(
                apiKey: $apiKey,
                customPrompt: $customPrompt,
                sessionType: sessionType
            )
        }
        .alert("Microphone Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable microphone access in Settings to use voice features.")
        }
    }
    
    private func setupServices() {
        // Load saved API key and prompt
        apiKey = UserDefaults.standard.string(forKey: "gemini_api_key") ?? ""
        customPrompt = UserDefaults.standard.string(forKey: "custom_prompt_\(sessionType.rawValue)") ?? ""
        
        // Configure Gemini service
        geminiService.configure(apiKey: apiKey, profile: sessionType, customPrompt: customPrompt)
        
        // Setup audio service callbacks
        audioService.onTranscriptionUpdate = { transcription in
            conversationManager.updateTranscription(transcription)
            
            // Send to Gemini for guidance
            Task {
                await geminiService.sendTranscription(transcription)
            }
        }
        
        // Setup Gemini service callbacks
        geminiService.onResponseReceived = { response in
            DispatchQueue.main.async {
                self.currentGuidance = response
                
                // Save conversation turn
                self.conversationManager.saveConversationTurn(
                    transcription: self.conversationManager.currentTranscription,
                    aiResponse: response
                )
            }
        }
        
        geminiService.onError = { error in
            print("Gemini error: \(error)")
        }
        
        // Start conversation session
        conversationManager.startNewSession()
    }
    
    private func toggleRecording() {
        if audioService.isRecording {
            audioService.stopRecording()
        } else {
            Task {
                let hasPermission = await audioService.requestPermissions()
                if hasPermission {
                    // Start Gemini session if not connected
                    if !geminiService.isConnected && !apiKey.isEmpty {
                        do {
                            try await geminiService.startSession()
                        } catch {
                            print("Failed to start Gemini session: \(error)")
                        }
                    }
                    
                    audioService.startRecording()
                } else {
                    showingPermissionAlert = true
                }
            }
        }
    }
}

struct SoundWaveView: View {
    let isActive: Bool
    let audioLevel: Float
    
    @State private var animationValues: [CGFloat] = Array(repeating: 0.3, count: 5)
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple, .red],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 4)
                    .frame(height: isActive ? animationValues[index] * 100 : 20)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1),
                        value: isActive
                    )
            }
        }
        .onAppear {
            if isActive {
                startAnimation()
            }
        }
        .onChange(of: isActive) { active in
            if active {
                startAnimation()
            }
        }
        .onChange(of: audioLevel) { level in
            updateAnimationWithAudioLevel(level)
        }
    }
    
    private func startAnimation() {
        for i in 0..<5 {
            animationValues[i] = CGFloat.random(in: 0.3...1.0)
        }
    }
    
    private func updateAnimationWithAudioLevel(_ level: Float) {
        let normalizedLevel = min(max(CGFloat(level), 0.1), 1.0)
        for i in 0..<5 {
            animationValues[i] = normalizedLevel * CGFloat.random(in: 0.5...1.5)
        }
    }
}

#Preview {
    AIAssistantView(sessionType: .interview) {
        // Preview back action
    }
}
