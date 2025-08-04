import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let name: String
    let createdAt: Date
    
    init(email: String, name: String) {
        self.id = UUID()
        self.email = email
        self.name = name
        self.createdAt = Date()
    }
}

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    func login(email: String, password: String) {
        // Simulate authentication - in real app, this would call your backend
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.currentUser = User(email: email, name: self.extractNameFromEmail(email))
            self.isAuthenticated = true
        }
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
    }
    
    private func extractNameFromEmail(_ email: String) -> String {
        let components = email.components(separatedBy: "@")
        return components.first?.capitalized ?? "User"
    }
}
