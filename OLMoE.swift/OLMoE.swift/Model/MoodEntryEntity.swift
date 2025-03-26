import Foundation
import CoreData

/**
 MoodEntryEntity is the Core Data managed object class for storing mood entries.
 This replaces the plain struct MoodEntry with a persistent Core Data entity.
 */
@objc(MoodEntryEntity)
public class MoodEntryEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var moodValue: Int16
    @NSManaged public var moodEmoji: String?
    @NSManaged public var moodDescription: String?
    @NSManaged public var note: String?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Set default values upon creation
        id = UUID()
        date = Date()
    }
}

// MARK: - Fetch Request
extension MoodEntryEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoodEntryEntity> {
        return NSFetchRequest<MoodEntryEntity>(entityName: "MoodEntryEntity")
    }
} 