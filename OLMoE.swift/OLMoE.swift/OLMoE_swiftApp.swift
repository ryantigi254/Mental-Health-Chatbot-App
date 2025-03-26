import SwiftUI
import Foundation

<<<<<<< HEAD
// Embed ThemeManager directly in this file to avoid import issues
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    init() {
        // Default to system setting, fallback to true (dark mode)
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

@main
struct OLMoE_swiftApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.font, .manrope())
                .preferredColorScheme(themeManager.colorScheme)
                .environmentObject(themeManager)
=======
@main
struct OLMoE_swiftApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.font, .manrope())
                .environment(\.colorScheme, .dark)
                .preferredColorScheme(.dark)
>>>>>>> 800cefc0 (Initial commit- Research was already conducted for more info refer to the research structure file)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        print("Background URL session: \(identifier)")
        completionHandler()
    }
}
