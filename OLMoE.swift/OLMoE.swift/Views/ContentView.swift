//
//  ContentView.swift
//  OLMoE.swift
//
//  Created by Luca Soldaini on 2024-09-16.
//


import SwiftUI
import os

class Bot: LLM {
    static let modelFileURL = URL.modelsDirectory.appendingPathComponent(AppConstants.Model.filename).appendingPathExtension("gguf")

    convenience init() {
        guard FileManager.default.fileExists(atPath: Bot.modelFileURL.path) else {
            fatalError("Model file not found. Please download it first.")
        }

        self.init(from: Bot.modelFileURL, template: .OLMoE())
        
        // Ensure the bot starts with a clean slate
        Task { @MainActor in
            await self.clearHistory()
        }
    }
}

struct BotView: View {
    @StateObject var bot: Bot
    @State var input = ""
    @State private var isGenerating = false
    @State private var stopSubmitted = false
    @State private var scrollToBottom = false
    @State private var isSharing = false
    @State private var shareURL: URL?
    @State private var showShareSheet = false
    @State private var isSharingConfirmationVisible = false
    @State private var isDeleteHistoryConfirmationVisible = false
    @State private var isScrolledToBottom = true
    @FocusState private var isTextEditorFocused: Bool
    let disclaimerHandlers: DisclaimerHandlers

    // Add new state for text sharing
    @State private var showTextShareSheet = false
    
    // Add state for suggested prompts
    @State private var suggestedPrompts: [String] = [
        "How can I manage stress better?",
        "Tell me about mindfulness techniques",
        "I'm feeling anxious today",
        "Help me build self-confidence",
        "What are some productivity tips?"
    ]
    
    // Track whether suggestions should be shown
    @State private var showSuggestions = true

    private var hasValidInput: Bool {
        !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isInputDisabled: Bool {
        isGenerating || isSharing
    }

    private var isDeleteButtonDisabled: Bool {
        isInputDisabled || bot.history.isEmpty
    }

    private var isChatEmpty: Bool {
        bot.history.isEmpty && !isGenerating && bot.output.isEmpty
    }

    init(_ bot: Bot, disclaimerHandlers: DisclaimerHandlers) {
        _bot = StateObject(wrappedValue: bot)
        self.disclaimerHandlers = disclaimerHandlers
        // Initialize suggested prompts will be handled in onAppear
    }

    func shouldShowScrollButton() -> Bool {
        return !isScrolledToBottom
    }

    func respond() {
        isGenerating = true
        isTextEditorFocused = false
        stopSubmitted = false
        let originalInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        input = "" // Clear the input after sending

        // Add the user message to history immediately
        bot.history.append(Chat(role: .user, content: originalInput))
        Task {
            await bot.respond(to: originalInput)
            await MainActor.run {
                bot.setOutput(to: "")
                isGenerating = false
                stopSubmitted = false
                // Update suggested prompts based on the conversation
                updateSuggestedPrompts()
            }
        }
    }

    // Method to update suggested prompts based on conversation context
    private func updateSuggestedPrompts() {
        // Don't show suggestions if the conversation is empty
        if bot.history.isEmpty {
            showSuggestions = true
            suggestedPrompts = [
                "How can I manage stress better?",
                "Tell me about mindfulness techniques",
                "I'm feeling anxious today",
                "Help me build self-confidence",
                "What are some productivity tips?"
            ]
            return
        }
        
        // Get the last few messages to determine context
        let recentMessages = bot.history.suffix(4)
        
        // Look for keywords in the conversation to suggest relevant follow-ups
        let conversationText = recentMessages.map { $0.content.lowercased() }.joined(separator: " ")
        
        if conversationText.contains("stress") || conversationText.contains("anxiety") || conversationText.contains("worry") {
            suggestedPrompts = [
                "What are some breathing exercises for anxiety?",
                "How can I improve my sleep quality?",
                "Tell me about meditation techniques",
                "What foods help reduce stress?",
                "How does exercise impact mental health?"
            ]
        } else if conversationText.contains("productivity") || conversationText.contains("work") || conversationText.contains("focus") {
            suggestedPrompts = [
                "How can I overcome procrastination?",
                "Tell me about the Pomodoro technique",
                "What are some effective to-do list methods?",
                "How can I minimize distractions?",
                "What are good habits for better productivity?"
            ]
        } else if conversationText.contains("relationship") || conversationText.contains("friend") || conversationText.contains("partner") || conversationText.contains("social") {
            suggestedPrompts = [
                "How can I communicate better with others?",
                "Tips for resolving conflicts peacefully",
                "How do I set healthy boundaries?",
                "Ways to build deeper connections",
                "How to be more empathetic"
            ]
        } else if conversationText.contains("health") || conversationText.contains("fitness") || conversationText.contains("exercise") {
            suggestedPrompts = [
                "What's a good beginner workout routine?",
                "How much exercise do I need each week?",
                "Tips for staying motivated with fitness",
                "How does nutrition affect energy levels?",
                "What are signs of overtraining?"
            ]
        } else {
            // Default follow-up questions that work with most conversations
            suggestedPrompts = [
                "Can you explain that in more detail?",
                "How does that apply to daily life?",
                "What's the science behind that?",
                "Are there any alternatives to consider?",
                "What are common misconceptions about this?"
            ]
        }
    }

    func stop() {
        self.stopSubmitted = true
        Task {
            await bot.stop()
        }
    }

    func deleteHistory() {
        Task { @MainActor in
            await bot.clearHistory()
            bot.setOutput(to: "")
             input = "" // Clear the input
        }
    }

    private func formatConversationForSharing() -> String {
        let deviceName = UIDevice.current.model
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm a"
        let timestamp = dateFormatter.string(from: Date())

        let header = """
        Conversation with OLMoE (Open Language Mixture of Expert)
        ----------------------------------------

        """

        let conversation = bot.history.map { chat in
            let role = chat.role == .user ? "User" : "OLMoE"
            return "\(role): \(chat.content)"
        }.joined(separator: "\n\n")

        let footer = """

        ----------------------------------------
        Shared from OLMoE - AI2's Open Language Model
        https://github.com/allenai/OLMoE
        """

        return header + conversation + footer
    }

    func shareConversation() {
        isSharing = true
        disclaimerHandlers.setShowDisclaimerPage(false)
        Task {
            do {
                let attestationResult = try await AppAttestManager.performAttest()

                // Prepare payload
                let apiKey = Configuration.apiKey
                let apiUrl = Configuration.apiUrl

                let modelName = AppConstants.Model.filename
                let systemFingerprint = "\(modelName)-\(AppInfo.shared.appId)"

                let messages = bot.history.map { chat in
                    ["role": chat.role == .user ? "user" : "assistant", "content": chat.content]
                }

                let payload: [String: Any] = [
                    "model": modelName,
                    "system_fingerprint": systemFingerprint,
                    "created": Int(Date().timeIntervalSince1970),
                    "messages": messages,
                    "key_id": attestationResult.keyID,
                    "attestation_object": attestationResult.attestationObjectBase64
                ]

                let jsonData = try JSONSerialization.data(withJSONObject: payload)

                guard let url = URL(string: apiUrl), !apiUrl.isEmpty else {
                    print("Invalid URL")
                    await MainActor.run {
                        isSharing = false
                    }
                    return
                }

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
                request.httpBody = jsonData
                let (data, response) = try await URLSession.shared.data(for: request)

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    let responseString = String(data: data, encoding: .utf8)!
                    if let jsonData = responseString.data(using: .utf8),
                       let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                       let body = jsonResult["body"] as? String,
                       let bodyData = body.data(using: .utf8),
                       let bodyJson = try JSONSerialization.jsonObject(with: bodyData, options: []) as? [String: Any],
                       let urlString = bodyJson["url"] as? String,
                       let url = URL(string: urlString) {
                        await MainActor.run {
                            self.shareURL = url
                            self.showShareSheet = true
                        }
                        print("Conversation shared successfully")
                    } else {
                        print("Failed to parse response")
                    }
                } else {
                    print("Failed to share conversation")
                }
            } catch {
                let attestError = error as NSError
                if attestError.domain == "AppAttest" {
                    print("Error: \(attestError.localizedDescription)")
                } else {
                    print("Error sharing conversation: \(error)")
                }
            }

            await MainActor.run {
                isSharing = false
            }
        }
    }

    @ViewBuilder
    func shareButton() -> some View {
        Button(action: {
            isTextEditorFocused = false
            // disclaimerHandlers.setActiveDisclaimer(Disclaimers.ShareDisclaimer())
            // disclaimerHandlers.setCancelAction({ disclaimerHandlers.setShowDisclaimerPage(false) })
            // disclaimerHandlers.setAllowOutsideTapDismiss(true)
            // disclaimerHandlers.setConfirmAction({ shareConversation() })
            // disclaimerHandlers.setShowDisclaimerPage(true)
            showTextShareSheet = true
        }) {
            HStack {
                if isSharing {
                    SpinnerView(color: Color("AccentColor"))
                } else {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            .foregroundColor(Color("TextColor"))
        }
        .disabled(isSharing || bot.history.isEmpty || isGenerating)
        .opacity(isSharing || bot.history.isEmpty || isGenerating ? 0.5 : 1)
    }

    @ViewBuilder
    func trashButton() -> some View {
        Button(action: {
            isTextEditorFocused = false
            isDeleteHistoryConfirmationVisible = true
            stop()
        }) {
            Image(systemName: "trash.fill")
                .foregroundColor(Color("TextColor"))
        }.alert("Delete history?", isPresented: $isDeleteHistoryConfirmationVisible, actions: {
            Button("Delete", action: deleteHistory)
            Button("Cancel", role: .cancel) {
                isDeleteHistoryConfirmationVisible = false
            }
        })
        .disabled(isDeleteButtonDisabled)
        .opacity(isDeleteButtonDisabled ? 0.5 : 1)
    }

    @ViewBuilder
    func suggestionsToggleButton() -> some View {
        Button(action: {
            withAnimation {
                showSuggestions.toggle()
            }
        }) {
            Image(systemName: showSuggestions ? "lightbulb.fill" : "lightbulb")
                .foregroundColor(Color("TextColor"))
        }
    }

    @ViewBuilder
    func scrollToBottomButton() -> some View {
        VStack {
            Spacer()

            Button(action: {
                scrollToBottom = true
            }) {
                Image(systemName: "arrow.down")
                    .aspectRatio(contentMode: .fit)
                    .padding(10)
                    .foregroundColor(Color("BackgroundColor"))
                    .background(Color("LightGreen"))
                    .clipShape(Circle())
            }
            .opacity(shouldShowScrollButton() ? 1 : 0)
            .transition(.opacity)
            .animation(
                shouldShowScrollButton()
                ? .easeIn(duration: 0.1)
                : .easeOut(duration: 0.3).delay(0.1),
                value: shouldShowScrollButton())
        }
        .padding([.bottom], 4)
    }

    var body: some View {
        GeometryReader { geometry in
            contentView(in: geometry)
        }
        .onAppear {
            // Initialize suggested prompts
            updateSuggestedPrompts()
        }
    }

    private func contentView(in geometry: GeometryProxy) -> some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading) {
                if !isChatEmpty {
                    ScrollViewReader { proxy in
                        ZStack {
                            ChatView(
                                history: bot.history,
                                output: bot.output.trimmingCharacters(in: .whitespacesAndNewlines),
                                isGenerating: $isGenerating,
                                isScrolledToBottom: $isScrolledToBottom,
                                stopSubmitted: $stopSubmitted
                            )
                                .onChange(of: scrollToBottom) { newValue in
                                    if newValue {
                                        withAnimation {
                                            proxy.scrollTo(ChatView.BottomID, anchor: .bottom)
                                        }
                                        scrollToBottom = false
                                    }
                                }
                                .gesture(TapGesture().onEnded({
                                    isTextEditorFocused = false
                                }))

                            scrollToBottomButton()
                        }
                    }
                } else {
                    ZStack {
                        VStack{
                            Spacer()
                            Image("Ai2Icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: min(geometry.size.width, geometry.size.height) * 0.18)
                                .colorMultiply(Color.accentColor)
                                .saturation(1.3)
                                .brightness(0.1)
                                .contrast(1.2)
                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                Spacer()

                if (isChatEmpty) {
                    BotChatBubble(
                        text: String(localized: "Welcome chat message", comment: "Default chat bubble when conversation is empty"), 
                        maxWidth: geometry.size.width,
                        isInitialGreeting: true
                    )
                }
                
                // Only show suggestions if enabled and not generating a response
                if showSuggestions && !isGenerating {
                    SuggestedPrompts(suggestions: suggestedPrompts) { prompt in
                        input = prompt
                        // Optionally auto-send the prompt
                        // respond()
                    }
                    .transition(.opacity)
                    .padding(.bottom, 8)
                }

                MessageInputView(
                    input: $input,
                    isGenerating: $isGenerating,
                    stopSubmitted: $stopSubmitted,
                    isTextEditorFocused: $isTextEditorFocused,
                    isInputDisabled: isInputDisabled,
                    hasValidInput: hasValidInput,
                    respond: respond,
                    stop: stop
                )
            }
            .padding(12)
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = shareURL {
                ActivityViewController(activityItems: [url])
            }
        }
        .sheet(isPresented: $showTextShareSheet) {
            ActivityViewController(activityItems: [formatConversationForSharing()])
        }
        .gesture(TapGesture().onEnded({
            isTextEditorFocused = false
        }))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                suggestionsToggleButton()
                shareButton()
                trashButton()
            }
        }
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}


// Add this struct to handle the UIActivityViewController
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}

struct ContentView: View {
    /// A shared instance of the background download manager.
    @StateObject private var downloadManager = BackgroundDownloadManager.shared

    /// The state of the disclaimer handling.
    @StateObject private var disclaimerState = DisclaimerState()

    /// The bot instance used for conversation.
    @State private var bot: Bot?

    /// A flag indicating whether to show the info page.
    @State private var showInfoPage: Bool = false

    /// A flag indicating whether the device is supported.
    @State private var isSupportedDevice: Bool = isDeviceSupported()

    /// A flag indicating whether to use mocked model responses.
    @State private var useMockedModelResponse: Bool = false

    /// Logger for tracking events in the ContentView.
    let logger = Logger(subsystem: "com.allenai.olmoe", category: "ContentView")

    /// A flag indicating whether to show the API settings.
    @State private var showApiSettings = false

    public var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    if !isSupportedDevice && !useMockedModelResponse {
                        UnsupportedDeviceView(
                            proceedAnyway: { isSupportedDevice = true },
                            proceedMocked: {
                                bot?.loopBackTestResponse = true
                                useMockedModelResponse = true
                            }
                        )
                    } else if let bot = bot {
                        BotView(bot, disclaimerHandlers: DisclaimerHandlers(
                            setActiveDisclaimer: { disclaimerState.activeDisclaimer = $0 },
                            setAllowOutsideTapDismiss: { disclaimerState.allowOutsideTapDismiss = $0 },
                            setCancelAction: { disclaimerState.onCancel = $0 },
                            setConfirmAction: { disclaimerState.onConfirm = $0 },
                            setShowDisclaimerPage: { disclaimerState.showDisclaimerPage = $0 }
                        ))
                    } else {
                        ModelDownloadView()
                    }
                }
                .onChange(of: downloadManager.isModelReady) { value in
                    if value && bot == nil {
                        initializeBot()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    AppToolbar(
                        leadingContent: {
                            InfoButton(action: { showInfoPage = true })
                        },
                        trailingContent: {
                            Button("API Settings") {
                                showApiSettings = true
                            }
                        }
                    )
                }
            }
            .onAppear {
                disclaimerState.showInitialDisclaimer()
            }
            .sheet(isPresented: $showInfoPage) {
                SheetWrapper {
                    InfoView(isPresented: $showInfoPage)
                }
            }
            .sheet(isPresented: $disclaimerState.showDisclaimerPage) {
                SheetWrapper {
                    DisclaimerPage(
                        allowOutsideTapDismiss: disclaimerState.allowOutsideTapDismiss,
                        isPresented: $disclaimerState.showDisclaimerPage,
                        message: disclaimerState.activeDisclaimer?.text ?? "",
                        title: disclaimerState.activeDisclaimer?.title ?? "",
                        titleText: disclaimerState.activeDisclaimer?.headerTextContent ?? [],
                        confirm: DisclaimerPage.PageButton(
                            text: disclaimerState.activeDisclaimer?.buttonText ?? "",
                            onTap: {
                                disclaimerState.onConfirm?()
                            }
                        ),
                        cancel: disclaimerState.onCancel.map { cancelAction in
                            DisclaimerPage.PageButton(
                                text: "Cancel",
                                onTap: {
                                    cancelAction()
                                    disclaimerState.activeDisclaimer = nil
                                }
                            )
                        }
                    )
                }
                .interactiveDismissDisabled(!disclaimerState.allowOutsideTapDismiss)
            }
            .sheet(isPresented: $showApiSettings) {
                ApiKeySettingsView()
            }
        }
    }

    /// Checks if the model is ready and initializes the bot if it is.
    private func checkModelAndInitializeBot() {
        if FileManager.default.fileExists(atPath: Bot.modelFileURL.path) {
            downloadManager.isModelReady = true
            initializeBot()
        }
    }

    /// Initializes the bot instance and sets the loopback test response flag.
    private func initializeBot() {
        bot = Bot()
        bot?.loopBackTestResponse = useMockedModelResponse
    }
}
