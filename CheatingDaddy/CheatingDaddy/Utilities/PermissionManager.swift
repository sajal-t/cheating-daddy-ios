import Foundation
import AVFoundation
import Speech

class PermissionManager: ObservableObject {
    @Published var microphonePermission: AVAudioSession.RecordPermission = .undetermined
    @Published var speechRecognitionPermission: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    
    init() {
        updatePermissionStatus()
    }
    
    func updatePermissionStatus() {
        microphonePermission = AVAudioSession.sharedInstance().recordPermission
        speechRecognitionPermission = SFSpeechRecognizer.authorizationStatus()
    }
    
    func requestMicrophonePermission() async -> Bool {
        let permission = await AVAudioSession.sharedInstance().requestRecordPermission()
        
        DispatchQueue.main.async {
            self.microphonePermission = AVAudioSession.sharedInstance().recordPermission
        }
        
        return permission
    }
    
    func requestSpeechRecognitionPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    self.speechRecognitionPermission = status
                }
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    func requestAllPermissions() async -> Bool {
        let micPermission = await requestMicrophonePermission()
        let speechPermission = await requestSpeechRecognitionPermission()
        
        return micPermission && speechPermission
    }
    
    var hasAllPermissions: Bool {
        return microphonePermission == .granted && speechRecognitionPermission == .authorized
    }
    
    var permissionStatusMessage: String {
        switch (microphonePermission, speechRecognitionPermission) {
        case (.granted, .authorized):
            return "All permissions granted"
        case (.denied, _), (_, .denied):
            return "Permissions denied. Please enable in Settings."
        case (.undetermined, _), (_, .notDetermined):
            return "Permissions required for voice features"
        default:
            return "Some permissions are missing"
        }
    }
    
    func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

// MARK: - Permission Status Helpers
extension AVAudioSession.RecordPermission {
    var isGranted: Bool {
        return self == .granted
    }
    
    var isDenied: Bool {
        return self == .denied
    }
    
    var displayName: String {
        switch self {
        case .granted:
            return "Granted"
        case .denied:
            return "Denied"
        case .undetermined:
            return "Not Requested"
        @unknown default:
            return "Unknown"
        }
    }
}

extension SFSpeechRecognizerAuthorizationStatus {
    var isAuthorized: Bool {
        return self == .authorized
    }
    
    var isDenied: Bool {
        return self == .denied
    }
    
    var displayName: String {
        switch self {
        case .authorized:
            return "Authorized"
        case .denied:
            return "Denied"
        case .notDetermined:
            return "Not Requested"
        case .restricted:
            return "Restricted"
        @unknown default:
            return "Unknown"
        }
    }
}
