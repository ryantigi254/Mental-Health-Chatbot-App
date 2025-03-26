import SwiftUI

struct SuggestedPrompts: View {
    var suggestions: [String]
    var onPromptSelected: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(suggestions, id: \.self) { prompt in
                    Button(action: {
                        onPromptSelected(prompt)
                    }) {
                        Text(prompt)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(16)
                            .foregroundColor(.accentColor)
                            .lineLimit(1)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 50)
    }
}

// Preview
#Preview {
    SuggestedPrompts(
        suggestions: [
            "How can I manage stress better?",
            "Tell me about mindfulness techniques",
            "I'm feeling anxious today",
            "Help me build self-confidence"
        ],
        onPromptSelected: { _ in }
    )
} 