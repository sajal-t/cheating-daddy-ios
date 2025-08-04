import Foundation
import SwiftUI
import AVFoundation

// MARK: - String Extensions
extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func truncated(to length: Int) -> String {
        if self.count <= length {
            return self
        } else {
            return String(self.prefix(length)) + "..."
        }
    }
}

// MARK: - Date Extensions
extension Date {
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

// MARK: - Color Extensions
extension Color {
    static let theme = ColorTheme()
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ColorTheme {
    let primary = Color.purple
    let secondary = Color.blue
    let accent = Color.green
    let background = Color.black
    let surface = Color.white.opacity(0.1)
    let onSurface = Color.white
    let onSurfaceSecondary = Color.white.opacity(0.7)
    let error = Color.red
    let warning = Color.orange
    let success = Color.green
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                    .fill(Constants.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                            .stroke(Constants.Colors.cardBorder, lineWidth: 1)
                    )
            )
    }
    
    func glassEffect() -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Constants.UI.cornerRadius))
    }
    
    func shimmer(active: Bool = true) -> some View {
        self.modifier(ShimmerModifier(active: active))
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    let active: Bool
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: phase)
                    .animation(
                        active ? .linear(duration: 1.5).repeatForever(autoreverses: false) : .default,
                        value: phase
                    )
            )
            .onAppear {
                if active {
                    phase = 300
                }
            }
            .clipped()
    }
}

// MARK: - AVAudioSession Extensions
extension AVAudioSession {
    func requestRecordPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            self.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}

// MARK: - UserDefaults Extensions
extension UserDefaults {
    func setSessionType(_ sessionType: SessionType, forKey key: String) {
        set(sessionType.rawValue, forKey: key)
    }
    
    func sessionType(forKey key: String) -> SessionType? {
        guard let rawValue = string(forKey: key) else { return nil }
        return SessionType(rawValue: rawValue)
    }
}

// MARK: - Bundle Extensions
extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var appName: String {
        return infoDictionary?["CFBundleDisplayName"] as? String ?? 
               infoDictionary?["CFBundleName"] as? String ?? 
               "Cheating Daddy"
    }
}

// MARK: - Haptic Feedback
extension UIImpactFeedbackGenerator {
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
}

extension UINotificationFeedbackGenerator {
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

// MARK: - Array Extensions
extension Array where Element == Message {
    func lastUserMessage() -> Message? {
        return self.last { $0.sender == .user }
    }
    
    func lastAIMessage() -> Message? {
        return self.last { $0.sender == .ai }
    }
}

// MARK: - TimeInterval Extensions
extension TimeInterval {
    func formattedDuration() -> String {
        let hours = Int(self) / 3600
        let minutes = Int(self) % 3600 / 60
        let seconds = Int(self) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}
