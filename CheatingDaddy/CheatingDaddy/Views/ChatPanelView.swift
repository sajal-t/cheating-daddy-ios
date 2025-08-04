import SwiftUI

struct ChatPanelView: View {
    @Binding var isShowing: Bool
    @ObservedObject var conversationManager: ConversationManager
    @ObservedObject var geminiService: GeminiService
    
    @State private var messageText = ""
    @State private var isTyping = false
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Backdrop
                Color.black.opacity(0.3)
                    .onTapGesture {
                        isShowing = false
                    }
                
                // Chat panel
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { isShowing = false }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text("AI Chat")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: clearChat) {
                            Image(systemName: "trash")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        Rectangle()
                            .fill(Color.black.opacity(0.8))
                    )
                    
                    // Messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(conversationManager.messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                                
                                if conversationManager.isAITyping {
                                    TypingIndicator()
                                        .id("typing")
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                        }
                        .onChange(of: conversationManager.messages.count) { _ in
                            withAnimation(.easeOut(duration: 0.3)) {
                                if let lastMessage = conversationManager.messages.last {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: conversationManager.isAITyping) { typing in
                            if typing {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    proxy.scrollTo("typing", anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    // Input area
                    VStack(spacing: 12) {
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        HStack(spacing: 12) {
                            TextField("Type a message...", text: $messageText, axis: .vertical)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                                .foregroundColor(.white)
                                .lineLimit(1...4)
                                .onSubmit {
                                    sendMessage()
                                }
                            
                            Button(action: sendMessage) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .white.opacity(0.3) : .purple)
                            }
                            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .background(
                        Rectangle()
                            .fill(Color.black.opacity(0.8))
                    )
                }
                .frame(width: geometry.size.width * 0.85)
                .background(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.95),
                            Color.black.opacity(0.9),
                            Color.purple.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
        }
        .ignoresSafeArea()
    }
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // Add user message
        let userMessage = Message(content: text, sender: .user)
        conversationManager.addMessage(userMessage)
        
        // Clear input
        messageText = ""
        
        // Show typing indicator
        conversationManager.setAITyping(true)
        
        // Send to Gemini
        Task {
            let response = await geminiService.sendChatMessage(text)
            
            DispatchQueue.main.async {
                // Hide typing indicator
                conversationManager.setAITyping(false)
                
                // Add AI response
                let aiMessage = Message(content: response, sender: .ai)
                conversationManager.addMessage(aiMessage)
            }
        }
    }
    
    private func clearChat() {
        conversationManager.messages.removeAll()
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(message.sender == .user ? Color.purple : Color.white.opacity(0.1))
                    )
                
                Text(message.formattedTime)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.horizontal, 4)
            }
            
            if message.sender == .ai {
                Spacer(minLength: 50)
            }
        }
    }
}

struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 8, height: 8)
                            .scaleEffect(animationOffset == CGFloat(index) ? 1.2 : 0.8)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: animationOffset
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.1))
                )
                
                Text("AI is typing...")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.horizontal, 4)
            }
            
            Spacer(minLength: 50)
        }
        .onAppear {
            animationOffset = 0
        }
    }
}

#Preview {
    ChatPanelView(
        isShowing: .constant(true),
        conversationManager: ConversationManager(),
        geminiService: GeminiService()
    )
}
