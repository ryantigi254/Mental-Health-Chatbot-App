import SwiftUI

@main
struct OLMoEApp: App {
    // Initialize the persistent controller for Core Data
    @StateObject private var dataController = MoodDatabaseManager.shared
    
    // Initialize Core Data persistence
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
                // Inject Core Data context into the environment
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                // Make the mood data manager available throughout the app
                .environmentObject(dataController)
        }
    }
} 