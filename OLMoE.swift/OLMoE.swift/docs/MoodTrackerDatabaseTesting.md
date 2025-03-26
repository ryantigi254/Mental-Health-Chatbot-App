# Mood Tracker Database Testing Guide

This document outlines how to test the Core Data implementation for the Mood Tracker feature to ensure it works as intended and is secure.

## Database Implementation Overview

The Mood Tracker uses Core Data with the following components:

1. **MoodEntryEntity**: Core Data managed object class for storing mood entries
2. **PersistenceController**: Manages the Core Data stack and persistent container
3. **MoodDatabaseManager**: Handles CRUD operations and business logic
4. **NSManagedObjectModel+MoodTracker**: Programmatically creates the Core Data model

## Testing the Database Implementation

### 1. Basic Functionality Testing

#### Data Persistence
- Add a mood entry and close the app
- Reopen the app and verify the entry is still there
- Check that the "You've already recorded your mood today" message appears if you've already logged a mood today

#### Data Retrieval
- Add multiple mood entries over several days
- Test each time period filter (Week, Month, 6 Months, Year)
- Verify that the chart and distribution views show the correct data

#### Data Deletion
- Test the "Reset All Entries" button
- Confirm the confirmation dialog appears
- After confirming, verify all entries are removed

### 2. Security Testing

#### Data Protection
The implementation uses iOS data protection with `FileProtectionType.complete`, which means:
- Data is encrypted when the device is locked
- Data is only accessible when the device is unlocked

To test this:
1. Add some mood entries
2. Lock the device
3. The data should be encrypted and inaccessible
4. Unlock the device and verify the data is accessible again

#### SQLite Security
The implementation uses several SQLite optimizations and security features:
- Write-Ahead Logging (WAL) for better concurrency
- Foreign key constraints enabled
- Auto-vacuum for optimized storage

### 3. Error Handling Testing

#### Corrupt Database Recovery
To test how the app handles database corruption:
1. Add some mood entries
2. Force quit the app during a save operation (if possible)
3. Restart the app and check if it recovers gracefully

#### Storage Space Handling
To test how the app handles low storage:
1. Fill the device storage to near capacity
2. Try to add new mood entries
3. Verify the app handles the error gracefully

### 4. Performance Testing

#### Large Dataset Handling
To test performance with a large dataset:
1. Add many mood entries (can be simulated in development)
2. Test the loading time and responsiveness of the app
3. Check memory usage during chart rendering

### 5. Unit Testing

Create unit tests for:
- `MoodDatabaseManager.saveMood()`
- `MoodDatabaseManager.getMoodEntries(for:)`
- `MoodDatabaseManager.checkIfAnsweredToday()`
- `MoodDatabaseManager.clearAllEntries()`

Example test for saving a mood:
```swift
func testSaveMood() {
    let manager = MoodDatabaseManager.shared
    let initialCount = manager.moodEntries.count
    
    manager.saveMood(.happy, note: "Test note")
    
    XCTAssertEqual(manager.moodEntries.count, initialCount + 1)
    XCTAssertTrue(manager.hasAnsweredToday)
    
    let latestEntry = manager.moodEntries.first
    XCTAssertEqual(latestEntry?.moodEmoji, "🙂")
    XCTAssertEqual(latestEntry?.moodDescription, "Happy")
    XCTAssertEqual(latestEntry?.note, "Test note")
}
```

## Debugging Tools

### Core Data Debug Options

Add these to your scheme's launch arguments for debugging:
- `-com.apple.CoreData.SQLDebug 1` (SQL statements)
- `-com.apple.CoreData.Logging.stderr 1` (Error logging)

### Database Inspection

Use the Core Data debug tools in Xcode:
1. Run the app in debug mode
2. Open the Debug Navigator (Cmd+6)
3. Select "Core Data" to view the database contents

## Common Issues and Solutions

### Issue: Data Not Persisting
- Check if `saveContext()` is being called
- Verify the persistent store URL is correct
- Check for errors in the console during save operations

### Issue: Slow Performance
- Add indices to frequently queried attributes
- Use batch operations for large updates
- Implement fetch request limits and sorting

### Issue: Memory Leaks
- Check for retain cycles in the database manager
- Ensure large result sets are properly managed
- Use `NSFetchedResultsController` for large datasets

## Conclusion

A well-tested Core Data implementation ensures reliable data persistence, good performance, and security for user data. Regular testing of these aspects will help maintain a high-quality mood tracking feature. 