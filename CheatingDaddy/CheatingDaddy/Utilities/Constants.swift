import Foundation
import SwiftUI

struct Constants {
    
    // MARK: - API Configuration
    struct API {
        static let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent"
        static let timeout: TimeInterval = 30.0
        static let maxRetries = 3
    }
    
    // MARK: - Audio Configuration
    struct Audio {
        static let sampleRate: Double = 16000.0
        static let bufferSize: AVAudioFrameCount = 1024
        static let audioFormat = "wav"
        static let maxRecordingDuration: TimeInterval = 3600 // 1 hour
    }
    
    // MARK: - UI Configuration
    struct UI {
        static let cornerRadius: CGFloat = 12.0
        static let largePadding: CGFloat = 24.0
        static let mediumPadding: CGFloat = 16.0
        static let smallPadding: CGFloat = 8.0
        
        static let animationDuration: Double = 0.3
        static let longAnimationDuration: Double = 0.6
        
        static let shadowRadius: CGFloat = 10.0
        static let shadowOpacity: Float = 0.1
    }
    
    // MARK: - Colors
    struct Colors {
        static let primaryGradient = LinearGradient(
            colors: [Color.purple, Color.blue],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        static let backgroundGradient = LinearGradient(
            colors: [
                Color.black,
                Color.black.opacity(0.9),
                Color.purple.opacity(0.3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let cardBackground = Color.white.opacity(0.1)
        static let cardBorder = Color.white.opacity(0.2)
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.7)
        static let textTertiary = Color.white.opacity(0.5)
    }
    
    // MARK: - UserDefaults Keys
    struct UserDefaultsKeys {
        static let geminiAPIKey = "gemini_api_key"
        static let customPromptPrefix = "custom_prompt_"
        static let isFirstLaunch = "is_first_launch"
        static let lastSessionType = "last_session_type"
        static let totalSessions = "total_sessions"
        static let totalHours = "total_hours"
    }
    
    // MARK: - Error Messages
    struct ErrorMessages {
        static let noMicrophonePermission = "Microphone permission is required to use voice features."
        static let noSpeechPermission = "Speech recognition permission is required for transcription."
        static let noAPIKey = "Please configure your Gemini API key in Settings."
        static let connectionFailed = "Failed to connect to AI service. Please check your internet connection."
        static let transcriptionFailed = "Speech recognition failed. Please try again."
        static let audioCaptureFailed = "Failed to start audio capture. Please check your microphone."
    }
    
    // MARK: - App Information
    struct AppInfo {
        static let name = "Cheating Daddy"
        static let version = "1.0.0"
        static let description = "AI-Powered Real-time Guidance"
        static let supportEmail = "support@cheatingdaddy.com"
        static let privacyPolicyURL = "https://cheatingdaddy.com/privacy"
        static let termsOfServiceURL = "https://cheatingdaddy.com/terms"
    }
    
    // MARK: - Notification Names
    struct NotificationNames {
        static let sessionStarted = Notification.Name("SessionStarted")
        static let sessionEnded = Notification.Name("SessionEnded")
        static let transcriptionUpdated = Notification.Name("TranscriptionUpdated")
        static let aiResponseReceived = Notification.Name("AIResponseReceived")
    }
}

// MARK: - Environment Values
struct APIKeyEnvironmentKey: EnvironmentKey {
    static let defaultValue: String = ""
}

extension EnvironmentValues {
    var apiKey: String {
        get { self[APIKeyEnvironmentKey.self] }
        set { self[APIKeyEnvironmentKey.self] = newValue }
    }
}
