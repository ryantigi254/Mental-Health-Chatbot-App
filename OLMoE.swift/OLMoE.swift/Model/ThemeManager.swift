import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    init() {
        // Default to system setting, fallback to false (light mode)
        if let savedMode = UserDefaults.standard.object(forKey: "isDarkMode") as? Bool {
            self.isDarkMode = savedMode
        } else {
            self.isDarkMode = false // Default to light mode for testing
        }
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
    }
    
    // Get the current color scheme
    var colorScheme: ColorScheme {
        return isDarkMode ? .dark : .light
    }
} 