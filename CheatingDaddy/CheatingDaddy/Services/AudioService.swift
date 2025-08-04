import AVFoundation
import Speech
import Combine

class AudioService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var audioLevel: Float = 0.0
    @Published var hasPermission = false
    
    private var audioEngine: AVAudioEngine?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioSession: AVAudioSession?
    
    // Callbacks
    var onTranscriptionUpdate: ((String) -> Void)?
    var onAudioData: ((Data) -> Void)?
    
    override init() {
        super.init()
        setupAudioSession()
        setupSpeechRecognizer()
    }
    
    private func setupAudioSession() {
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession?.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers])
            try audioSession?.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupSpeechRecognizer() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        speechRecognizer?.delegate = self
    }
    
    func requestPermissions() async -> Bool {
        // Request microphone permission
        let microphoneStatus = await AVAudioSession.sharedInstance().requestRecordPermission()
        
        // Request speech recognition permission
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
        
        let hasPermission = microphoneStatus && speechStatus
        
        DispatchQueue.main.async {
            self.hasPermission = hasPermission
        }
        
        return hasPermission
    }
    
    func startRecording() {
        guard hasPermission else {
            print("No audio permissions granted")
            return
        }
        
        // Stop any existing recording
        stopRecording()
        
        // Setup audio engine
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Setup speech recognition
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Create recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result = result {
                let transcription = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self?.onTranscriptionUpdate?(transcription)
                }
            }
            
            if error != nil {
                self?.stopRecording()
            }
        }
        
        // Install tap on audio input
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, time in
            // Send audio buffer to speech recognition
            self?.recognitionRequest?.append(buffer)
            
            // Calculate audio level for visualization
            let channelData = buffer.floatChannelData?[0]
            let channelDataValue = channelData?.pointee ?? 0
            let audioLevel = abs(channelDataValue)
            
            DispatchQueue.main.async {
                self?.audioLevel = audioLevel
            }
            
            // Convert buffer to Data for Gemini API
            if let audioData = self?.bufferToData(buffer) {
                self?.onAudioData?(audioData)
            }
        }
        
        // Start audio engine
        do {
            try audioEngine.start()
            DispatchQueue.main.async {
                self.isRecording = true
            }
            print("Audio recording started")
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    func stopRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        
        DispatchQueue.main.async {
            self.isRecording = false
            self.audioLevel = 0.0
        }
        
        print("Audio recording stopped")
    }
    
    private func bufferToData(_ buffer: AVAudioPCMBuffer) -> Data? {
        guard let channelData = buffer.floatChannelData?[0] else { return nil }
        
        let frameLength = Int(buffer.frameLength)
        let data = Data(bytes: channelData, count: frameLength * MemoryLayout<Float>.size)
        return data
    }
    
    deinit {
        stopRecording()
    }
}

// MARK: - SFSpeechRecognizerDelegate
extension AudioService: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("Speech recognizer availability changed: \(available)")
    }
}
