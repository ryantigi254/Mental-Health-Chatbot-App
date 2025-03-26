import SwiftUI

enum TabSelection: String, CaseIterable {
    case home = "Home"
    case moodTracker = "Mood Tracker"
    case settings = "Settings"
    
    var icon: String {
        switch self {
        case .home:
            return "bubble.left.fill"
        case .moodTracker:
            return "heart.fill"
        case .settings:
            return "gear"
        }
    }
}

struct HamburgerMenuView: View {
    @Binding var selectedTab: TabSelection
    @Binding var isMenuOpen: Bool
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Add some spacing at the top for better appearance
            Spacer()
                .frame(height: 20)
            
            ForEach(TabSelection.allCases, id: \.self) { tab in
                Button(action: {
                    // Use a consistent animation approach
                    // First select the tab immediately
                    selectedTab = tab
                    // Then close the menu
                    withAnimation(.easeOut(duration: 0.3)) {
                        isMenuOpen = false
                    }
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: tab.icon)
                            .font(.title2)
                        
                        Text(tab.rawValue)
                            .font(.headline)
                    }
                    .foregroundColor(selectedTab == tab ? .blue : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                }
            }
            
            Spacer()
            
            // Theme switcher in menu
            HStack {
                Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                    .foregroundColor(themeManager.isDarkMode ? .purple : .orange)
                    .font(.title2)
                
                Text(themeManager.isDarkMode ? "Dark Mode" : "Light Mode")
                    .font(.headline)
                
                Spacer()
                
                Toggle("", isOn: $themeManager.isDarkMode)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .labelsHidden()
            }
            .padding(.vertical, 12)
            
            Spacer()
                .frame(height: 20)
        }
        .padding(.top, 60) // Align with the navigation bar
        .padding(.horizontal, 24)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.vertical)
    }
}

#Preview {
    HamburgerMenuView(selectedTab: .constant(.home), isMenuOpen: .constant(true))
        .environmentObject(ThemeManager())
} 