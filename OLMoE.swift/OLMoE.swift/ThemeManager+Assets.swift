import SwiftUI

// This file ensures our custom colors are properly registered and accessible
extension Color {
    // Custom color for the BotView and conversation backgrounds
    static var conversationBackground: Color {
        Color("ConversationBackground", bundle: .main)
    }
}

// Extend the ThemeManager to provide consistent colors for the app
extension ThemeManager {
    // Get the appropriate background color for the home tab
    var homeBackgroundColor: Color {
        isDarkMode ? Color(.systemBackground) : Color.creamBackground
    }
    
    // Get the appropriate text color
    var primaryTextColor: Color {
        isDarkMode ? Color.white : Color.black.opacity(0.85)
    }
    
    // Get the appropriate background color for other screens
    var secondaryBackgroundColor: Color {
        isDarkMode ? Color(.systemBackground) : Color.white
    }
} 