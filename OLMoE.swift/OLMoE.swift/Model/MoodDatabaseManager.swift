import Foundation
import CoreData
import SwiftUI

/**
 MoodDatabaseManager is responsible for providing secure storage of mood tracking data
 using Apple's CoreData framework with data protection enabled.
 
 This class handles:
 - Database initialization and setup
 - Secure storage with iOS data protection
 - CRUD operations for mood entries
 - Database maintenance
 */
class MoodDatabaseManager: ObservableObject {
    // Shared instance for app-wide access
    static let shared = MoodDatabaseManager()
    
    // Published properties that the UI can observe
    @Published var moodEntries: [MoodEntryEntity] = []
    @Published var hasAnsweredToday: Bool = false
    
    // Core Data container and context
    private let persistenceController: PersistenceController
    private var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    // Private initializer for singleton pattern
    private init() {
        self.persistenceController = PersistenceController.shared
        loadMoodEntries()
        checkIfAnsweredToday()
        
        // Set up notification for database changes
        setupNotifications()
    }
    
    // MARK: - Data Operations
    
    /// Load all mood entries from the database
    func loadMoodEntries() {
        let fetchRequest: NSFetchRequest<MoodEntryEntity> = MoodEntryEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntryEntity.date, ascending: false)]
        
        do {
            moodEntries = try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching mood entries: \(error)")
            moodEntries = []
        }
    }
    
    /// Save a new mood entry to the database
    func saveMood(_ mood: MoodType, note: String? = nil) {
        let newEntry = MoodEntryEntity(context: viewContext)
        newEntry.id = UUID()
        newEntry.date = Date()
        newEntry.moodValue = Int16(mood.value)
        newEntry.moodEmoji = mood.rawValue
        newEntry.moodDescription = mood.description
        newEntry.note = note
        
        saveContext()
        loadMoodEntries()
        checkIfAnsweredToday()
    }
    
    /// Get mood entries for a specific time period
    func getMoodEntries(for period: TimePeriod) -> [MoodEntryEntity] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -period.days, to: Date()) ?? Date()
        
        return moodEntries.filter { entry in
            guard let date = entry.date else { return false }
            return date >= startDate
        }
    }
    
    /// Check if the user has already logged a mood today
    func checkIfAnsweredToday() {
        let calendar = Calendar.current
        hasAnsweredToday = moodEntries.contains { entry in
            guard let date = entry.date else { return false }
            return calendar.isDateInToday(date)
        }
    }
    
    /// Delete a specific mood entry
    func deleteMoodEntry(_ entry: MoodEntryEntity) {
        viewContext.delete(entry)
        saveContext()
        loadMoodEntries()
        checkIfAnsweredToday()
    }
    
    /// Clear all mood entries from the database
    func clearAllEntries() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MoodEntryEntity.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(batchDeleteRequest)
            try viewContext.save()
            moodEntries = []
            hasAnsweredToday = false
        } catch {
            print("Error clearing mood entries: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    /// Save changes to the persistent store
    private func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    /// Set up notifications for database changes
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(managedObjectContextDidChange),
            name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
            object: viewContext
        )
    }
    
    @objc private func managedObjectContextDidChange(_ notification: Notification) {
        loadMoodEntries()
        checkIfAnsweredToday()
    }
    
    // MARK: - Preview Helper
    
    /// Create a preview instance with sample data for SwiftUI previews
    static var preview: MoodDatabaseManager {
        let instance = MoodDatabaseManager()
        
        // Use the preview persistence controller
        let previewContext = PersistenceController.preview.container.viewContext
        
        // Load entries from the preview context
        let fetchRequest: NSFetchRequest<MoodEntryEntity> = MoodEntryEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntryEntity.date, ascending: false)]
        
        do {
            instance.moodEntries = try previewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching preview mood entries: \(error)")
        }
        
        return instance
    }
} 