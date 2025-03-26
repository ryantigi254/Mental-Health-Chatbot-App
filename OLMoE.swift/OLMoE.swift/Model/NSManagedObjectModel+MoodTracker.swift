import Foundation
import CoreData

extension NSManagedObjectModel {
    static func createMoodTrackerModel() -> NSManagedObjectModel {
        // Create a new model
        let model = NSManagedObjectModel()
        
        // Create the MoodEntryEntity
        let moodEntryEntity = NSEntityDescription()
        moodEntryEntity.name = "MoodEntryEntity"
        moodEntryEntity.managedObjectClassName = "MoodEntryEntity"
        
        // Define attributes
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = true
        
        let dateAttribute = NSAttributeDescription()
        dateAttribute.name = "date"
        dateAttribute.attributeType = .dateAttributeType
        dateAttribute.isOptional = true
        
        let moodValueAttribute = NSAttributeDescription()
        moodValueAttribute.name = "moodValue"
        moodValueAttribute.attributeType = .integer16AttributeType
        moodValueAttribute.isOptional = false
        moodValueAttribute.defaultValue = 3
        
        let moodEmojiAttribute = NSAttributeDescription()
        moodEmojiAttribute.name = "moodEmoji"
        moodEmojiAttribute.attributeType = .stringAttributeType
        moodEmojiAttribute.isOptional = true
        
        let moodDescriptionAttribute = NSAttributeDescription()
        moodDescriptionAttribute.name = "moodDescription"
        moodDescriptionAttribute.attributeType = .stringAttributeType
        moodDescriptionAttribute.isOptional = true
        
        let noteAttribute = NSAttributeDescription()
        noteAttribute.name = "note"
        noteAttribute.attributeType = .stringAttributeType
        noteAttribute.isOptional = true
        
        // Add attributes to entity
        moodEntryEntity.properties = [
            idAttribute,
            dateAttribute,
            moodValueAttribute,
            moodEmojiAttribute,
            moodDescriptionAttribute,
            noteAttribute
        ]
        
        // Add entity to model
        model.entities = [moodEntryEntity]
        
        return model
    }
} 