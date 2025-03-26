import SwiftUI

struct CrisisButtonView: View {
    @State private var showingOptions = false
    @Environment(\.horizontalSizeClass) var sizeClass
    
    // Allow customizing the style
    var isHeaderStyle: Bool = false
    
    var body: some View {
        Button(action: {
            showingOptions.toggle()
        }) {
            if isHeaderStyle {
                // Compact version for header
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                    .padding(8)
            } else {
                // Standard version
                Text("Crisis Help")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
        }
        .sheet(isPresented: $showingOptions) {
            NavigationView {
                List {
                    Section(header: Text("Emergency Services")) {
                        Link(destination: URL(string: "tel:999")!) {
                            Label("Emergency Services (999)", systemImage: "phone.fill")
                        }
                        
                        Link(destination: URL(string: "https://www.safezoneapp.com")!) {
                            Label("SafeZone App", systemImage: "shield.fill")
                        }
                    }
                    
                    Section(header: Text("Mental Health Support")) {
                        Link(destination: URL(string: "https://www.samaritans.org/how-we-can-help/contact-samaritan/")!) {
                            Label("Samaritans Support", systemImage: "person.fill.questionmark")
                        }
                        
                        Link(destination: URL(string: "https://www.nhs.uk/service-search/mental-health/find-an-urgent-mental-health-helpline")!) {
                            Label("NHS Urgent Mental Health", systemImage: "cross.fill")
                        }
                    }
                    
                    Section(header: Text("Self-Help Tools")) {
                        NavigationLink(destination: GroundingTechniqueView()) {
                            Label("5-4-3-2-1 Grounding", systemImage: "hand.raised.fill")
                        }
                        
                        NavigationLink(destination: BreathingExerciseView()) {
                            Label("Guided Breathing", systemImage: "lungs.fill")
                        }
                    }
                }
                .navigationTitle("Crisis Resources")
            }
        }
    }
}

struct GroundingTechniqueView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("5-4-3-2-1 Grounding Technique")
                    .font(.title)
                    .padding(.bottom)
                
                Group {
                    StepView(number: 5, sense: "things you can SEE", color: .blue)
                    StepView(number: 4, sense: "things you can FEEL", color: .green)
                    StepView(number: 3, sense: "things you can HEAR", color: .purple)
                    StepView(number: 2, sense: "things you can SMELL", color: .orange)
                    StepView(number: 1, sense: "thing you can TASTE", color: .red)
                }
            }
            .padding()
        }
        .navigationTitle("Grounding Exercise")
    }
}

struct StepView: View {
    let number: Int
    let sense: String
    let color: Color
    
    var body: some View {
        HStack {
            Text("\(number)")
                .font(.title)
                .bold()
                .foregroundColor(color)
            Text(sense)
                .font(.body)
        }
    }
}

struct BreathingExerciseView: View {
    @State private var selectedTechnique: BreathingTechnique?
    @State private var scale: CGFloat = 1.0
    @State private var isBreathing = false
    @State private var breathPhase = BreathPhase.inhale
    @State private var timer: Timer?
    @State private var secondsRemaining: Int = 0
    
    enum BreathingTechnique: String, CaseIterable {
        case boxBreathing = "4-4-4 Box Breathing"
        case relaxingBreath = "4-7-8 Relaxing Breath"
        case diaphragmatic = "Diaphragmatic Breathing"
        case breathFocus = "Breath Focus"
        
        var description: String {
            switch self {
            case .boxBreathing:
                return "Inhale (4s) → Hold (4s) → Exhale (4s) → Hold (4s)\nGreat for quick stress reduction"
            case .relaxingBreath:
                return "Inhale (4s) → Hold (7s) → Exhale (8s)\nPerfect for deep relaxation and sleep"
            case .diaphragmatic:
                return "Deep belly breathing with focus on diaphragm movement\nReduces stress and anxiety"
            case .breathFocus:
                return "Mindful breathing with counting\nEnhances focus and calm"
            }
        }
        
        var cycleTime: Int {
            switch self {
            case .boxBreathing: return 16
            case .relaxingBreath: return 19
            case .diaphragmatic: return 8
            case .breathFocus: return 10
            }
        }
    }
    
    enum BreathPhase {
        case inhale, holdInhale, exhale, holdExhale
        
        var instruction: String {
            switch self {
            case .inhale: return "Breathe In..."
            case .holdInhale: return "Hold..."
            case .exhale: return "Breathe Out..."
            case .holdExhale: return "Hold..."
            }
        }
    }
    
    var body: some View {
        if let technique = selectedTechnique {
            exerciseView(for: technique)
        } else {
            techniqueSelectionView()
        }
    }
    
    private func techniqueSelectionView() -> some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Choose a Breathing Technique")
                    .font(.title)
                    .padding(.top)
                
                ForEach(BreathingTechnique.allCases, id: \.self) { technique in
                    Button(action: {
                        selectedTechnique = technique
                    }) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(technique.rawValue)
                                .font(.headline)
                            Text(technique.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .navigationTitle("Breathing Exercises")
    }
    
    private func exerciseView(for technique: BreathingTechnique) -> some View {
        VStack {
            Text(breathPhase.instruction)
                .font(.title)
                .padding()
            
            Text("\(secondsRemaining)")
                .font(.largeTitle)
                .bold()
                .padding()
            
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 200, height: 200)
                .scaleEffect(scale)
                .animation(
                    Animation.easeInOut(duration: Double(getPhaseTime(for: technique, phase: breathPhase))),
                    value: scale
                )
            
            Text("Follow the circle")
                .padding()
            
            Button("Stop Exercise") {
                stopExercise()
                selectedTechnique = nil
            }
            .padding()
            .foregroundColor(.red)
        }
        .navigationTitle(technique.rawValue)
        .onAppear {
            startExercise(technique: technique)
        }
        .onDisappear {
            stopExercise()
        }
    }
    
    private func startExercise(technique: BreathingTechnique) {
        breathPhase = .inhale
        updateBreathingAnimation(technique: technique)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                updateBreathingPhase(technique: technique)
            }
        }
    }
    
    private func stopExercise() {
        timer?.invalidate()
        timer = nil
        scale = 1.0
        isBreathing = false
    }
    
    private func getPhaseTime(for technique: BreathingTechnique, phase: BreathPhase) -> Int {
        switch technique {
        case .boxBreathing:
            return 4 // All phases are 4 seconds
        case .relaxingBreath:
            switch phase {
            case .inhale: return 4
            case .holdInhale: return 7
            case .exhale: return 8
            case .holdExhale: return 0
            }
        case .diaphragmatic:
            switch phase {
            case .inhale: return 4
            case .exhale: return 4
            default: return 0
            }
        case .breathFocus:
            switch phase {
            case .inhale: return 5
            case .exhale: return 5
            default: return 0
            }
        }
    }
    
    private func updateBreathingPhase(technique: BreathingTechnique) {
        switch breathPhase {
        case .inhale:
            breathPhase = technique == .boxBreathing || technique == .relaxingBreath ? .holdInhale : .exhale
        case .holdInhale:
            breathPhase = .exhale
        case .exhale:
            breathPhase = technique == .boxBreathing ? .holdExhale : .inhale
        case .holdExhale:
            breathPhase = .inhale
        }
        updateBreathingAnimation(technique: technique)
    }
    
    private func updateBreathingAnimation(technique: BreathingTechnique) {
        secondsRemaining = getPhaseTime(for: technique, phase: breathPhase)
        
        switch breathPhase {
        case .inhale:
            scale = 1.5
        case .holdInhale:
            scale = 1.5
        case .exhale:
            scale = 1.0
        case .holdExhale:
            scale = 1.0
        }
    }
}

#Preview {
    CrisisButtonView()
} 