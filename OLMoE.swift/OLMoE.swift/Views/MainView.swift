import SwiftUI

// TopNavigationBar - extracted to its own view for stability
struct TopNavigationBar: View {
    let selectedTab: TabSelection
    @Binding var isMenuOpen: Bool
    let hasAcceptedDisclaimer: Bool
    @EnvironmentObject private var themeManager: ThemeManager
    var resetBot: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation(.easeOut(duration: 0.3)) {
                    isMenuOpen.toggle()
                }
            }) {
                Image(systemName: "line.horizontal.3")
                    .font(.title)
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
            }
            .padding(.leading, 12)
            
            Spacer()
            
            // Make the title tappable to reset the bot when in home tab
            if selectedTab == .home {
                Button(action: {
                    resetBot?()
                }) {
                    Text(selectedTab.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .fixedSize()
                }
            } else {
                Text(selectedTab.rawValue)
                    .font(.headline)
                    .fixedSize()
            }
            
            Spacer()
            
            // Crisis button in the top bar - only show after disclaimer is accepted
            if hasAcceptedDisclaimer {
                CrisisButtonView(isHeaderStyle: true)
                    .padding(.trailing, 12)
                    .frame(width: 44, height: 44, alignment: .center)
            } else {
                // Empty spacer for balance when crisis button is not shown
                Spacer()
                    .frame(width: 44, height: 44)
                    .padding(.trailing, 12)
            }
        }
        .frame(height: 60)
        .background(Color(.systemBackground))
        .shadow(color: themeManager.isDarkMode ? Color.black.opacity(0.3) : Color.gray.opacity(0.2), radius: 1)
    }
}

struct MainView: View {
    @State private var selectedTab: TabSelection = .home
    @State private var isMenuOpen = false
    @StateObject private var disclaimerState = DisclaimerState()
    @State private var bot: Bot?
    @State private var hasAcceptedDisclaimer = false
    @EnvironmentObject private var themeManager: ThemeManager
    
    // Add namespace for transitions
    @Namespace private var animation
    
    // Function to reset the bot
    private func resetBot() {
        // Create a new Bot instance to reset everything
        withAnimation {
            // First set to nil to trigger a visual refresh
            bot = nil
            
            // Then create a new instance after a small delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                bot = Bot()
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Main content based on selected tab
            VStack(spacing: 0) {
                // Top navigation bar - extracted to its own view for stability
                TopNavigationBar(
                    selectedTab: selectedTab,
                    isMenuOpen: $isMenuOpen,
                    hasAcceptedDisclaimer: hasAcceptedDisclaimer,
                    resetBot: resetBot
                )
                .zIndex(10) // Ensure navigation bar stays above all content
                
                // Tab content with fixed transitions
                ZStack {
                    switch selectedTab {
                    case .home:
                        // Add a custom background color for the home tab
                        ZStack {
                            // Custom cream background only for light mode, dark mode uses system background
                            Group {
                                if themeManager.isDarkMode {
                                    Color(.systemBackground)
                                } else {
                                    Color.creamBackground
                                }
                            }
                            .ignoresSafeArea()
                            
                            if let bot = bot {
                                if hasAcceptedDisclaimer {
                                    // Only show BotView with full functionality if disclaimer is accepted
                                    BotView(bot, disclaimerHandlers: DisclaimerHandlers(
                                        setActiveDisclaimer: { disclaimerState.activeDisclaimer = $0 },
                                        setAllowOutsideTapDismiss: { disclaimerState.allowOutsideTapDismiss = $0 },
                                        setCancelAction: { disclaimerState.onCancel = $0 },
                                        setConfirmAction: { disclaimerState.onConfirm = $0 },
                                        setShowDisclaimerPage: { disclaimerState.showDisclaimerPage = $0 }
                                    ))
                                } else {
                                    // Show empty view until terms are accepted
                                    Color.clear
                                }
                            } else {
                                ProgressView("Loading model...")
                            }
                        }
                        .id("home")
                        .transition(.asymmetric(
                            insertion: .opacity.animation(.easeOut(duration: 0.1)),
                            removal: .opacity.animation(.easeOut(duration: 0.1))
                        ))
                    case .moodTracker:
                        MoodTrackerView(selectedTab: $selectedTab)
                            .id("moodTracker")
                            .transition(.asymmetric(
                                insertion: .opacity.animation(.easeOut(duration: 0.1)),
                                removal: .opacity.animation(.easeOut(duration: 0.1))
                            ))
                    case .settings:
                        SettingsView()
                            .id("settings")
                            .transition(.asymmetric(
                                insertion: .opacity.animation(.easeOut(duration: 0.1)),
                                removal: .opacity.animation(.easeOut(duration: 0.1))
                            ))
                    }
                }
                .animation(.easeOut(duration: 0.1), value: selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .zIndex(0)
            
            // Overlay for hamburger menu background
            if isMenuOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.3)) {
                            isMenuOpen = false
                        }
                    }
                    .zIndex(1)
            }
            
            // Hamburger menu sliding from left
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    HamburgerMenuView(selectedTab: $selectedTab, isMenuOpen: $isMenuOpen)
                        .frame(width: min(geometry.size.width * 0.8, 300))
                        .background(Color(.systemBackground))
                        .offset(x: isMenuOpen ? 0 : -min(geometry.size.width * 0.8, 300))
                        .animation(.easeOut(duration: 0.3), value: isMenuOpen)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 3, y: 0)
                    
                    Spacer()
                }
                .edgesIgnoringSafeArea(.vertical)
            }
            .zIndex(2)
            
            // Disclaimer overlay
            if disclaimerState.showDisclaimerPage {
                DisclaimerPageView(
                    disclaimer: disclaimerState.activeDisclaimer!,
                    allowOutsideTapDismiss: disclaimerState.allowOutsideTapDismiss,
                    onCancel: disclaimerState.onCancel,
                    onConfirm: {
                        // When disclaimer is confirmed/accepted, set our flag
                        hasAcceptedDisclaimer = true
                        if let onConfirm = disclaimerState.onConfirm {
                            onConfirm()
                        }
                    }
                )
                .zIndex(3)
            }
        }
        .onAppear {
            disclaimerState.showInitialDisclaimer()
            bot = Bot()
            
            // Check if disclaimer has been previously accepted
            #if DEBUG
            // For debug, we can set this to true for easier testing
            hasAcceptedDisclaimer = false 
            #else
            hasAcceptedDisclaimer = UserDefaults.standard.bool(forKey: "hasSeenDisclaimer")
            #endif
        }
        // Add onChange to monitor tab selection changes
        .onChange(of: selectedTab) { oldValue, newValue in
            // When switching to home tab, create a new bot instance
            if newValue == .home && oldValue != .home {
                bot = Bot() // Reinitialize the bot when returning to home
            }
        }
    }
}

#Preview {
    MainView()
} 