import SwiftUI
import Charts
import CoreData

// Mood data model
struct MoodEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var mood: MoodType
    var note: String?
    
    enum CodingKeys: String, CodingKey {
        case id, date, mood, note
    }
}

// Mood types with emoji representation
enum MoodType: String, CaseIterable, Codable {
    case veryHappy = "😄"
    case happy = "🙂"
    case neutral = "😐"
    case sad = "😔"
    case verySad = "😢"
    
    var description: String {
        switch self {
        case .veryHappy: return "Very Happy"
        case .happy: return "Happy"
        case .neutral: return "Neutral"
        case .sad: return "Sad"
        case .verySad: return "Very Sad"
        }
    }
    
    var value: Int {
        switch self {
        case .veryHappy: return 5
        case .happy: return 4
        case .neutral: return 3
        case .sad: return 2
        case .verySad: return 1
        }
    }
    
    var color: Color {
        switch self {
        case .veryHappy: return .green
        case .happy: return .mint
        case .neutral: return .yellow
        case .sad: return .orange
        case .verySad: return .red
        }
    }
}

// Time period for chart display
enum TimePeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case sixMonths = "6 Months"
    case year = "Year"
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .sixMonths: return 180
        case .year: return 365
        }
    }
}

// Mood data manager
class MoodDataManager: ObservableObject {
    @Published var moodEntries: [MoodEntry] = []
    @Published var hasAnsweredToday = false
    
    private let saveKey = "moodEntries"
    
    init() {
        loadMoodEntries()
        checkIfAnsweredToday()
    }
    
    func saveMood(_ mood: MoodType, note: String? = nil) {
        let newEntry = MoodEntry(date: Date(), mood: mood, note: note)
        moodEntries.append(newEntry)
        hasAnsweredToday = true
        saveMoodEntries()
    }
    
    func getMoodEntries(for period: TimePeriod) -> [MoodEntry] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -period.days, to: Date()) ?? Date()
        
        return moodEntries.filter { $0.date >= startDate }
    }
    
    func resetAllEntries() {
        moodEntries = []
        hasAnsweredToday = false
        saveMoodEntries()
    }
    
    private func checkIfAnsweredToday() {
        let calendar = Calendar.current
        hasAnsweredToday = moodEntries.contains { entry in
            calendar.isDateInToday(entry.date)
        }
    }
    
    private func saveMoodEntries() {
        if let encoded = try? JSONEncoder().encode(moodEntries) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadMoodEntries() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data) {
                moodEntries = decoded
                return
            }
        }
        
        moodEntries = []
    }
}

struct MoodTrackerView: View {
    @State private var selectedMood: MoodType?
    @State private var showingMetrics = false
    @State private var selectedPeriod: TimePeriod = .week
    @State private var moodNote: String = ""
    @State private var showEntryView = false
    @State private var showResetConfirmation = false
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: TabSelection
    
    init(selectedTab: Binding<TabSelection> = .constant(.moodTracker)) {
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        VStack {
            if !showEntryView {
                moodQuestionView
            } else if !showingMetrics {
                moodConfirmationView
            } else {
                moodMetricsView
            }
        }
        .padding()
        .navigationTitle("Mood Tracker")
        .onAppear {
            if dataManager.hasAnsweredToday {
                showEntryView = true
                showingMetrics = true
            }
        }
    }
    
    // View that asks for today's mood
    private var moodQuestionView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("How are you feeling today?")
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            
            // Display mood options in a horizontal row
            HStack(spacing: 15) {
                ForEach(MoodType.allCases, id: \.self) { mood in
                    Button(action: {
                        selectedMood = mood
                        showEntryView = true
                    }) {
                        Text(mood.rawValue)
                            .font(.system(size: 28))
                            .frame(width: 55, height: 55)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.03))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Circle())
                }
                .padding(.horizontal, 30)
            } else {
                Text("How are you feeling today?")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 40)
                
                // Display mood options in a horizontal row
                HStack(spacing: 15) {
                    ForEach(MoodType.allCases, id: \.self) { mood in
                        Button(action: {
                            selectedMood = mood
                            showEntryView = true
                        }) {
                            Text(mood.rawValue)
                                .font(.system(size: 40))
                                .frame(width: 70, height: 70)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.03))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contentShape(Circle())
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
            }
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // View shown after recording mood
    private var moodConfirmationView: some View {
        VStack(spacing: 20) {
            if let selectedMood = selectedMood {
                Text(selectedMood.rawValue)
                    .font(.system(size: 70))
                    .padding(.bottom, 10)
                
                Text("You're feeling \(selectedMood.description.lowercased()) today")
                    .font(.title2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Would you like to add a note about how you're feeling?")
                    .font(.headline)
                    .padding(.top, 20)
                
                TextEditor(text: $moodNote)
                    .frame(height: 120)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding(.vertical)
            
            HStack(spacing: 15) {
                Button(action: {
                    if let mood = selectedMood {
                        moodDatabase.saveMood(mood, note: moodNote.isEmpty ? nil : moodNote)
                        showingMetrics = true
                    }
                }) {
                    Text("Save")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    showEntryView = false
                    selectedMood = nil
                    moodNote = ""
                }) {
                    Text("Cancel")
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    // View for displaying mood metrics
    private var moodMetricsView: some View {
        ScrollView {
            VStack {
                // Period selector
                Picker("Time Period", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.bottom)
                
                // Mood chart
                moodChart
                    .frame(height: 250)
                    .padding()
                
                // Mood distribution
                moodDistribution
                    .padding()
                
                Button(action: {
                    selectedTab = .home
                }) {
                    Text("Done")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.vertical)
                
                Button(action: {
                    showResetConfirmation = true
                }) {
                    Text("Reset All Entries")
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding(.bottom)
            }
            .padding(.horizontal)
        }
        .alert("Reset All Entries", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {
                showResetConfirmation = false
            }
            Button("Reset", role: .destructive) {
                dataManager.resetAllEntries()
                showResetConfirmation = false
                showingMetrics = false
                showEntryView = false
                selectedMood = nil
            }
        } message: {
            Text("This will permanently delete all your mood entries. This action cannot be undone.")
        }
    }
    
    // Chart showing mood over time
    private var moodChart: some View {
        let entries = moodDatabase.getMoodEntries(for: selectedPeriod)
        
        return Chart {
            ForEach(entries) { entry in
                PointMark(
                    x: .value("Date", entry.date ?? Date()),
                    y: .value("Mood", Int(entry.moodValue))
                )
                .foregroundStyle(Color.blue)
                .symbolSize(CGSize(width: 15, height: 15))
            }
            
            if !entries.isEmpty {
                ForEach(entries) { entry in
                    LineMark(
                        x: .value("Date", entry.date ?? Date()),
                        y: .value("Mood", Int(entry.moodValue))
                    )
                    .foregroundStyle(Color.blue.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                }
            }
        }
        .chartYScale(domain: 1...5)
        .chartYAxis {
            AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        let moodTypes = MoodType.allCases
                        if intValue >= 1 && intValue <= moodTypes.count {
                            Text(moodTypes[moodTypes.count - intValue].rawValue)
                        }
                    }
                }
            }
        }
    }
    
    // Mood distribution visualization
    private var moodDistribution: some View {
        let entries = moodDatabase.getMoodEntries(for: selectedPeriod)
        let moodCounts = Dictionary(grouping: entries) { entry -> MoodType? in
            guard let emoji = entry.moodEmoji else { return nil }
            return MoodType.allCases.first { $0.rawValue == emoji }
        }.mapValues { $0.count }
        
        return VStack(alignment: .leading, spacing: 15) {
            Text("Mood Distribution")
                .font(.headline)
                .padding(.bottom, 5)
            
            ForEach(MoodType.allCases, id: \.self) { mood in
                HStack {
                    Text(mood.rawValue)
                        .font(.title3)
                    
                    Text(mood.description)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(moodCounts[mood] ?? 0)")
                        .fontWeight(.bold)
                }
                .padding(.vertical, 5)
            }
            
            if !entries.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Notes")
                        .font(.headline)
                        .padding(.top, 20)
                        .padding(.bottom, 5)
                    
                    ForEach(entries.prefix(3)) { entry in
                        if let note = entry.note, !note.isEmpty, let date = entry.date {
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text(entry.moodEmoji ?? "")
                                    Text(formatDate(date))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(note)
                                    .font(.body)
                                    .padding(.leading, 5)
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
    }
    
    // Helper function to format dates
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    MoodTrackerView()
        .environmentObject(MoodDatabaseManager.preview)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 