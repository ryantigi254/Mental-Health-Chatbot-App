import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Appearance")) {
                    HStack {
                        Toggle(isOn: $themeManager.isDarkMode) {
                            HStack {
                                Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                                    .foregroundColor(themeManager.isDarkMode ? .purple : .orange)
                                    .font(.system(size: 20))
                                    .frame(width: 28, height: 28)
                                
                                Text("Dark Mode")
                                    .font(.headline)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                            .frame(width: 28, height: 28)
                        
                        Text("Version")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
                
                // Add more settings sections as needed
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
} 