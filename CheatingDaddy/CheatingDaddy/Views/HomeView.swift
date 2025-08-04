import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var sessionManager = SessionManager()
    @State private var activeTab = "home"
    @State private var showingAIAssistant = false
    @State private var selectedSessionType: SessionType = .interview
    
    private let stats = [
        Stat(label: "Sessions", value: "24", icon: "calendar"),
        Stat(label: "Hours", value: "18.5", icon: "clock"),
        Stat(label: "Success Rate", value: "92%", icon: "chart.line.uptrend.xyaxis"),
        Stat(label: "Achievements", value: "8", icon: "award")
    ]
    
    var body: some View {
        NavigationView {
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
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Good afternoon")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text(authManager.currentUser?.name ?? "User")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Button(action: { authManager.logout() }) {
                                Image(systemName: "person.circle")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white.opacity(0.8))
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(Color.white.opacity(0.1))
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                        
                        // Stats
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(stats, id: \.label) { stat in
                                StatCard(stat: stat)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Quick Actions
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Quick Start")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 12) {
                                    ForEach([SessionType.interview, SessionType.sales, SessionType.negotiation], id: \.self) { sessionType in
                                        QuickActionCard(sessionType: sessionType) {
                                            selectedSessionType = sessionType
                                            showingAIAssistant = true
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // Recent Sessions
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Recent Sessions")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Button("View All") {
                                        // Handle view all
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.purple)
                                }
                                
                                VStack(spacing: 12) {
                                    ForEach(sessionManager.recentSessions) { session in
                                        RecentSessionCard(session: session)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 100) // Space for bottom navigation
                    }
                    
                    Spacer()
                }
                
                // Bottom Navigation
                VStack {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        BottomNavItem(
                            icon: "house.fill",
                            title: "Home",
                            isActive: activeTab == "home"
                        ) {
                            activeTab = "home"
                        }
                        
                        BottomNavItem(
                            icon: "message.circle.fill",
                            title: "Sessions",
                            isActive: activeTab == "sessions"
                        ) {
                            activeTab = "sessions"
                        }
                        
                        BottomNavItem(
                            icon: "gearshape.fill",
                            title: "Settings",
                            isActive: activeTab == "settings"
                        ) {
                            activeTab = "settings"
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showingAIAssistant) {
            AIAssistantView(sessionType: selectedSessionType) {
                showingAIAssistant = false
            }
        }
    }
}

struct Stat {
    let label: String
    let value: String
    let icon: String
}

struct StatCard: View {
    let stat: Stat
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: stat.icon)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.6))
            
            Text(stat.value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(stat.label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
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

struct QuickActionCard: View {
    let sessionType: SessionType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [sessionType.color, sessionType.color.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: sessionType.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
                    Text(sessionType.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(sessionType.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecentSessionCard: View {
    let session: Session
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: session.type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(session.type.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.type.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text("\(session.formattedDate) • \(session.formattedDuration)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(16)
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

struct BottomNavItem: View {
    let icon: String
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(isActive ? .white : .white.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isActive ? Color.white.opacity(0.2) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

class SessionManager: ObservableObject {
    @Published var recentSessions: [Session] = []
    
    init() {
        loadRecentSessions()
    }
    
    private func loadRecentSessions() {
        // Mock data - in real app, load from storage
        var session1 = Session(type: .interview)
        session1.complete()
        session1.startTime = Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date()
        session1.endTime = Calendar.current.date(byAdding: .minute, value: -45, to: Date())
        
        var session2 = Session(type: .sales)
        session2.complete()
        session2.startTime = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        session2.endTime = Calendar.current.date(byAdding: .minute, value: -32, to: session2.startTime)
        
        var session3 = Session(type: .negotiation)
        session3.complete()
        session3.startTime = Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
        session3.endTime = Calendar.current.date(byAdding: .minute, value: -72, to: session3.startTime)
        
        recentSessions = [session1, session2, session3]
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthenticationManager())
}
