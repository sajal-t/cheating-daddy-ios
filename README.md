# Cheating Daddy iOS

A native iOS Swift/SwiftUI app that provides AI-powered real-time guidance for live conversations using Google Gemini API.

## Features

- **Real-time Audio Capture**: Continuously listen and analyze conversations using the device microphone
- **AI-Powered Insights**: Google Gemini provides context-aware guidance and suggestions
- **Multiple Session Types**: Support for interviews, sales calls, meetings, negotiations, and exams
- **Live Chat Interface**: Direct interaction with AI through a chat panel
- **iOS-Native Design**: Built with SwiftUI following iOS design guidelines
- **Privacy-Focused**: All audio processing happens locally, only transcriptions are sent to AI

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Google Gemini API Key

## Setup Instructions

### 1. Clone the Repository
```bash
git clone <repository-url>
cd cheating-daddy/iOS
```

### 2. Open in Xcode
```bash
open CheatingDaddy.xcodeproj
```

### 3. Configure API Key
1. Get your free Google Gemini API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Launch the app and go to Settings
3. Enter your API key in the "Google Gemini API Key" field
4. Save the settings

### 4. Build and Run
1. Select your target device or simulator
2. Press Cmd+R to build and run the app

## Project Structure

```
CheatingDaddy/
├── CheatingDaddyApp.swift          # Main app entry point
├── ContentView.swift               # Root coordinator view
├── Models/
│   ├── User.swift                  # User model and authentication
│   ├── Session.swift               # Session types and management
│   └── Message.swift               # Chat messages and conversation
├── Views/
│   ├── LoginView.swift             # Authentication screen
│   ├── HomeView.swift              # Main dashboard
│   ├── AIAssistantView.swift       # Core AI session screen
│   ├── ChatPanelView.swift         # Chat interface overlay
│   └── SettingsView.swift          # Configuration screen
├── Services/
│   ├── AudioService.swift          # Microphone capture and speech recognition
│   └── GeminiService.swift         # Google Gemini API integration
├── Utilities/
│   ├── Constants.swift             # App constants and configuration
│   ├── Extensions.swift            # Swift extensions and helpers
│   └── PermissionManager.swift     # iOS permissions management
└── Assets.xcassets/                # App icons and colors
```

## Key Components

### AudioService
- Handles microphone permissions and audio capture
- Provides real-time speech-to-text transcription
- Manages audio session and recording state
- Calculates audio levels for visualization

### GeminiService
- Integrates with Google Gemini API
- Manages different conversation profiles (interview, sales, etc.)
- Handles real-time AI responses
- Maintains conversation context and history

### Session Types
- **Interview**: Job interview coaching and guidance
- **Sales**: Sales call optimization and pitch assistance
- **Meeting**: Meeting participation and focus assistance
- **Negotiation**: Strategic negotiation guidance
- **Exam**: Quick answers and test assistance

## Permissions

The app requires the following iOS permissions:
- **Microphone Access**: For audio capture during sessions
- **Speech Recognition**: For converting speech to text

These permissions are requested automatically when starting a session.

## Usage

1. **Login**: Enter any email/password combination (demo authentication)
2. **Select Session Type**: Choose from interview, sales call, meeting, etc.
3. **Configure Settings**: Add your Gemini API key and custom context
4. **Start Session**: Tap the microphone button to begin recording
5. **Get AI Guidance**: View real-time suggestions in the guidance area
6. **Use Chat**: Tap the chat button for direct AI interaction
7. **End Session**: Tap the X button to stop and return to home

## Customization

### Adding Custom Prompts
Each session type supports custom context prompts:
1. Go to Settings during a session
2. Add specific context in the "Custom Context" field
3. Examples:
   - **Interview**: Job description, company info, your background
   - **Sales**: Product details, target audience, pricing
   - **Meeting**: Meeting agenda, your role, objectives

### Modifying Session Types
To add new session types:
1. Update the `SessionType` enum in `Models/Session.swift`
2. Add corresponding prompts in `GeminiService.swift`
3. Update UI icons and colors as needed

## API Integration

The app uses Google Gemini API for AI responses:
- **Endpoint**: `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent`
- **Authentication**: API key in query parameter
- **Request Format**: JSON with conversation context and user input
- **Response Format**: JSON with AI-generated guidance

## Privacy & Security

- Audio is processed locally on device
- Only text transcriptions are sent to Google Gemini
- API keys are stored securely in iOS Keychain
- No conversation data is permanently stored on servers
- Users can clear chat history at any time

## Troubleshooting

### Common Issues

**"No microphone permission"**
- Go to iOS Settings > Privacy & Security > Microphone
- Enable access for Cheating Daddy

**"API key required"**
- Get your API key from Google AI Studio
- Enter it in the app's Settings screen

**"Connection failed"**
- Check your internet connection
- Verify your API key is correct
- Ensure Gemini API is available in your region

**"Speech recognition failed"**
- Check microphone permissions
- Ensure device microphone is working
- Try speaking more clearly

## Development

### Adding New Features
1. Follow SwiftUI best practices
2. Use the existing service architecture
3. Maintain iOS design guidelines
4. Add appropriate error handling
5. Update this README with new features

### Testing
- Test on physical devices for audio features
- Verify permissions flow works correctly
- Test with different API key scenarios
- Validate offline behavior

## License

This project is licensed under the GPL-3.0 License - see the original project for details.

## Support

For issues and support:
- Check the troubleshooting section above
- Review iOS console logs for detailed error messages
- Ensure all permissions are granted
- Verify API key configuration

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on iOS devices
5. Submit a pull request

---

**Note**: This is a native iOS conversion of the original Electron-based Cheating Daddy app. The core AI functionality remains the same, but the implementation is optimized for iOS with native audio capture and SwiftUI interface.
