import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    
    private let features = [
        Feature(
            icon: "mic.fill",
            title: "Real-time Audio Capture",
            description: "Continuously listen and analyze conversations",
            color: .purple
        ),
        Feature(
            icon: "brain.head.profile",
            title: "AI-Powered Insights",
            description: "Google Gemini provides context-aware guidance",
            color: .blue
        ),
        Feature(
            icon: "person.3.fill",
            title: "Live Scenarios",
            description: "Perfect for interviews, sales calls, negotiations",
            color: .green
        ),
        Feature(
            icon: "target",
            title: "Instant Guidance",
            description: "Get suggestions and responses in real-time",
            color: .orange
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
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
                    .frame(width: 200, height: 200)
                    .blur(radius: 60)
                    .offset(x: -100, y: -200)
                
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 60)
                    .offset(x: 100, y: 200)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        VStack(spacing: 16) {
                            Spacer(minLength: 60)
                            
                            // App icon/logo
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 60, weight: .light))
                                .foregroundColor(.white)
                                .opacity(0.9)
                            
                            VStack(spacing: 8) {
                                Text("Cheating Daddy")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("AI-Powered Real-time Guidance")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(.bottom, 40)
                        
                        // Login form
                        VStack(spacing: 20) {
                            VStack(spacing: 16) {
                                // Email field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Email")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    TextField("Enter your email", text: $email)
                                        .textFieldStyle(CustomTextFieldStyle())
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .autocorrectionDisabled()
                                }
                                
                                // Password field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Password")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    HStack {
                                        Group {
                                            if showPassword {
                                                TextField("Enter your password", text: $password)
                                            } else {
                                                SecureField("Enter your password", text: $password)
                                            }
                                        }
                                        .textFieldStyle(PlainTextFieldStyle())
                                        
                                        Button(action: { showPassword.toggle() }) {
                                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                            
                            // Login button
                            Button(action: handleLogin) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("Sign In")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        colors: [Color.purple, Color.blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(isLoading || email.isEmpty || password.isEmpty)
                            .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                        
                        // Features section
                        VStack(spacing: 24) {
                            Text("Features")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 32)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                ForEach(features, id: \.title) { feature in
                                    FeatureCard(feature: feature)
                                }
                            }
                            .padding(.horizontal, 32)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
        }
    }
    
    private func handleLogin() {
        isLoading = true
        authManager.login(email: email, password: password)
        
        // Reset loading state after authentication completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
        }
    }
}

struct Feature {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct FeatureCard: View {
    let feature: Feature
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: feature.icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(feature.color)
            
            VStack(spacing: 4) {
                Text(feature.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(feature.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .foregroundColor(.white)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}
