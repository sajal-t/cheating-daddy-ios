import Foundation
import SwiftUI

enum SessionType: String, CaseIterable, Codable {
    case interview = "interview"
    case sales = "sales"
    case meeting = "meeting"
    case negotiation = "negotiation"
    case exam = "exam"
    
    var displayName: String {
        switch self {
        case .interview:
            return "Job Interview"
        case .sales:
            return "Sales Call"
        case .meeting:
            return "Meeting"
        case .negotiation:
            return "Negotiation"
        case .exam:
            return "Exam"
        }
    }
    
    var description: String {
        switch self {
        case .interview:
            return "Get real-time coaching"
        case .sales:
            return "Optimize your pitch"
        case .meeting:
            return "Stay on track"
        case .negotiation:
            return "Strategic guidance"
        case .exam:
            return "Quick answers"
        }
    }
    
    var icon: String {
        switch self {
        case .interview:
            return "briefcase.fill"
        case .sales:
            return "phone.fill"
        case .meeting:
            return "person.3.fill"
        case .negotiation:
            return "handshake.fill"
        case .exam:
            return "graduationcap.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .interview:
            return .blue
        case .sales:
            return .green
        case .meeting:
            return .orange
        case .negotiation:
            return .purple
        case .exam:
            return .red
        }
    }
}

enum SessionStatus: String, Codable {
    case active = "active"
    case completed = "completed"
    case paused = "paused"
}

struct Session: Identifiable, Codable {
    let id: UUID
    let type: SessionType
    let startTime: Date
    var endTime: Date?
    var status: SessionStatus
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(remainingMinutes) min"
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(startTime) {
            formatter.dateFormat = "'Today', h:mm a"
        } else if calendar.isDateInYesterday(startTime) {
            return "Yesterday"
        } else {
            let daysDiff = calendar.dateComponents([.day], from: startTime, to: Date()).day ?? 0
            if daysDiff <= 7 {
                return "\(daysDiff) days ago"
            } else {
                formatter.dateFormat = "MMM d"
            }
        }
        
        return formatter.string(from: startTime)
    }
    
    init(type: SessionType) {
        self.id = UUID()
        self.type = type
        self.startTime = Date()
        self.status = .active
    }
    
    mutating func complete() {
        self.endTime = Date()
        self.status = .completed
    }
    
    mutating func pause() {
        self.status = .paused
    }
    
    mutating func resume() {
        self.status = .active
    }
}
