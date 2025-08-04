import SwiftUI

struct SettingsView: View {
    @Binding var apiKey: String
    @Binding var customPrompt: String
    let sessionType: SessionType
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingAPIKeyInfo = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Session Type Info
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: sessionType.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(sessionType.color)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(sessionType.displayName)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text("Configure AI behavior for this session type")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // API Key Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Google Gemini API Key")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: { showingAPIKeyInfo = true }) {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                SecureField("Enter your Gemini API key", text: $apiKey)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                
                                Text("Required for AI responses. Get your free API key from Google AI Studio.")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        
                        // Custom Prompt Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Custom Context")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Add specific context for better AI responses:")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                TextEditor(text: $customPrompt)
                                    .frame(minHeight: 120)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                    .foregroundColor(.white)
                                    .overlay(
                                        Group {
                                            if customPrompt.isEmpty {
                                                VStack {
                                                    HStack {
                                                        Text(getPlaceholderText())
                                                            .foregroundColor(.white.opacity(0.5))
                                                            .font(.body)
                                                        Spacer()
                                                    }
                                                    Spacer()
                                                }
                                                .padding(16)
                                                .allowsHitTesting(false)
                                            }
                                        }
                                    )
                                
                                Text("Examples: job description, company info, your background, specific topics")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        
                        // Save Button
                        Button(action: saveSettings) {
                            Text("Save Settings")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        colors: [Color.purple, Color.blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            loadSettings()
        }
        .alert("API Key Information", isPresented: $showingAPIKeyInfo) {
            Button("Get API Key") {
                if let url = URL(string: "https://makersuite.google.com/app/apikey") {
                    UIApplication.shared.open(url)
                }
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text("You need a Google Gemini API key to use AI features. Visit Google AI Studio to get your free API key.")
        }
    }
    
    private func getPlaceholderText() -> String {
        switch sessionType {
        case .interview:
            return "e.g., Job: Senior iOS Developer at TechCorp\nCompany: Leading fintech startup\nBackground: 5 years iOS development, Swift expert"
        case .sales:
            return "e.g., Product: CRM Software\nTarget: Small businesses\nPrice: $99/month\nKey benefits: Automation, analytics, integrations"
        case .meeting:
            return "e.g., Meeting: Q4 Planning\nRole: Product Manager\nGoals: Discuss roadmap, resource allocation"
        case .negotiation:
            return "e.g., Context: Salary negotiation\nPosition: Software Engineer\nCurrent offer: $120k\nTarget: $140k"
        case .exam:
            return "e.g., Subject: Computer Science\nTopic: Data Structures and Algorithms\nLevel: University level"
        }
    }
    
    private func loadSettings() {
        apiKey = UserDefaults.standard.string(forKey: "gemini_api_key") ?? ""
        customPrompt = UserDefaults.standard.string(forKey: "custom_prompt_\(sessionType.rawValue)") ?? ""
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(apiKey, forKey: "gemini_api_key")
        UserDefaults.standard.set(customPrompt, forKey: "custom_prompt_\(sessionType.rawValue)")
        dismiss()
    }
}

#Preview {
    SettingsView(
        apiKey: .constant(""),
        customPrompt: .constant(""),
        sessionType: .interview
    )
}
