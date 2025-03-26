import Foundation
import CoreData

/**
 PersistenceController is responsible for initializing the Core Data stack
 and providing a central point of access to the persistent container.
 */
struct PersistenceController {
    // Shared instance for app-wide access
    static let shared = PersistenceController()
    
    // Storage for Core Data
    let container: NSPersistentContainer
    
    // Initialize the Core Data stack
    init(inMemory: Bool = false) {
        // Create custom model and register the MoodEntryEntity
        let managedObjectModel = NSManagedObjectModel.createMoodTrackerModel()
        container = NSPersistentContainer(name: "MoodTrackerModel", managedObjectModel: managedObjectModel)
        
        // Configure persistence with security options
        let description = inMemory 
            ? NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
            : NSPersistentStoreDescription()
        
        if !inMemory {
            // Enable data protection - complete protection means the data is encrypted when device is locked
            description.setOption(FileProtectionType.complete as NSObject, 
                                  forKey: NSPersistentStoreFileProtectionKey)
            
            // Set storage type to SQLite
            description.type = NSSQLiteStoreType
            
            // Configure SQLite optimization options
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            
            // Additional SQLite configurations for optimized performance 
            let pragmaOptions: [String: String] = [
                "journal_mode": "WAL",      // Write-Ahead Logging for better concurrency
                "synchronous": "NORMAL",    // Balance between safety and performance
                "auto_vacuum": "FULL",      // Keep database file size optimized
                "foreign_keys": "ON"        // Enforce referential integrity
            ]
            
            description.setOption(pragmaOptions as NSDictionary, forKey: NSSQLitePragmasOption)
        }
        
        container.persistentStoreDescriptions = [description]
        
        // Load the persistent store
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Replace this implementation with code to handle the error appropriately.
                 
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // Configure the context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Test Support
    
    // A test store for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        // Create 5 example mood entries
        let viewContext = controller.container.viewContext
        let previewEntries: [(moodValue: Int16, emoji: String, description: String, note: String?, daysAgo: Int)] = [
            (5, "😄", "Very Happy", "Had a great day at work!", 0),
            (4, "🙂", "Happy", nil, 1),
            (3, "😐", "Neutral", "Feeling just okay today", 2),
            (2, "😔", "Sad", "Stressed about deadlines", 4),
            (1, "😢", "Very Sad", nil, 6)
        ]
        
        for (index, entry) in previewEntries.enumerated() {
            let newEntry = MoodEntryEntity(context: viewContext)
            newEntry.id = UUID()
            newEntry.date = Calendar.current.date(byAdding: .day, value: -entry.daysAgo, to: Date())
            newEntry.moodValue = entry.moodValue
            newEntry.moodEmoji = entry.emoji
            newEntry.moodDescription = entry.description
            newEntry.note = entry.note
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
} 