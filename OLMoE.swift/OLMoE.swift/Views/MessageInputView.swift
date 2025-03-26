//
//  MessageInputView.swift
//  OLMoE.swift
//
//  Created by Stanley Jovel on 11/19/24.
//


import SwiftUI
<<<<<<< HEAD
import PhotosUI

#if os(iOS)
import UIKit
#endif

// A simple theme manager for this file only (temporary solution)
class SimpleTheme {
    var isDarkMode: Bool = false
}
=======
>>>>>>> 800cefc0 (Initial commit- Research was already conducted for more info refer to the research structure file)

struct MessageInputView: View {
    @Binding var input: String
    @Binding var isGenerating: Bool
    @Binding var stopSubmitted: Bool
    @FocusState.Binding var isTextEditorFocused: Bool
    let isInputDisabled: Bool
    let hasValidInput: Bool
    let respond: () -> Void
    let stop: () -> Void
<<<<<<< HEAD
    
    // Create a simple theme instead of using ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    private var isDarkMode: Bool {
        colorScheme == .dark
    }
    
    // Helper function to dismiss keyboard
    private func dismissKeyboard() {
        #if os(iOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
    
    // State for handling photo selection and menu
    @State private var showPhotoOptions: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var showPHPicker: Bool = false
    @State private var showCamera: Bool = false
    
    #if os(iOS)
    @State private var selectedImages: [UIImage] = []
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    #else
    @State private var selectedImages: [Any] = []
    #endif
    
    // Background color for the input field based on theme
    private var inputBackgroundColor: Color {
        #if os(iOS)
        isDarkMode ? Color(UIColor.systemGray6) : Color.white
        #else
        isDarkMode ? Color.gray.opacity(0.2) : Color.white
        #endif
    }
    
    // Border color for the input field based on theme
    private var inputBorderColor: Color {
        isDarkMode ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3)
    }
    
    // Send button color
    private var sendButtonColor: Color {
        hasValidInput ? Color.blue : micButtonColor
    }
    
    // Mic button color with better dark mode support
    private var micButtonColor: Color {
        isDarkMode ? Color.gray : Color.primary
    }
    
    // Icon color for the send/mic button to ensure good contrast
    private var buttonIconColor: Color {
        if hasValidInput {
            // Paper plane icon is always white
            return .white
        } else {
            // Mic icon uses a contrasting color (dark on light, light on dark)
            return isDarkMode ? .black : .white
        }
    }
    
    // Container background color
    private var containerBackgroundColor: Color {
        #if os(iOS)
        isDarkMode ? Color(UIColor.systemGray6) : Color(UIColor.systemBackground)
        #else
        isDarkMode ? Color.gray.opacity(0.2) : Color.white
        #endif
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 8) {
                // Plus button with menu
                Button(action: {
                    showPhotoOptions = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                        .frame(width: 30, height: 30)
                }
                .padding(.leading, 8)
                .confirmationDialog("Add Content", isPresented: $showPhotoOptions, titleVisibility: .visible) {
                    Button("Attach Photos") {
                        showPHPicker = true
                    }
                    
                    #if os(iOS)
                    Button("Take Photo") {
                        sourceType = .camera
                        showImagePicker = true
                    }
                    #endif
                }
                
                // Main text input field with rounded background
                HStack {
                    // Display selected image if available
                    #if os(iOS)
                    if !selectedImages.isEmpty {
                        HStack {
                            Image(uiImage: selectedImages[0])
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            
                            // Show count indicator if more than one image
                            if selectedImages.count > 1 {
                                Text("+\(selectedImages.count - 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(Color.blue)
                                    )
                            }
                            
                            Spacer()
                            
                            // Button to remove images
                            Button(action: {
                                self.selectedImages = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 4)
                        }
                        .frame(maxWidth: 120)
                    }
                    #endif
                    
                    TextField("Message OLMoE", text: $input, axis: .vertical)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 10)
                        .font(.body)
                        .foregroundColor(Color.primary)
                        .lineLimit(10)
                        .focused($isTextEditorFocused)
                        .onChange(of: isTextEditorFocused) { _, isFocused in
                            if !isFocused {
                                dismissKeyboard()
                            }
                        }
                        .disabled(isInputDisabled)
                        .opacity(isInputDisabled ? 0.6 : 1)
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(inputBorderColor, lineWidth: 1)
                        .background(RoundedRectangle(cornerRadius: 20).fill(inputBackgroundColor))
                )
                
                // Send/Stop button
                ZStack {
                    if isGenerating && !stopSubmitted {
                        Button(action: stop) {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(Color.red))
                        }
                    } else {
                        Button(action: respond) {
                            Image(systemName: hasValidInput ? "paperplane.fill" : "mic.fill")
                                .font(.system(size: 18))
                                .foregroundColor(buttonIconColor)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(sendButtonColor))
                        }
                        .disabled(!hasValidInput && isInputDisabled)
                    }
                }
                .onTapGesture {
                    isTextEditorFocused = false
                }
                .padding(.trailing, 8)
            }
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(containerBackgroundColor)
                    .shadow(color: isDarkMode ? Color.black.opacity(0.3) : Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
            .padding(.horizontal, 8)
            .padding(.bottom, 4)
            #if os(iOS)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImages: $selectedImages, sourceType: sourceType)
            }
            .sheet(isPresented: $showPHPicker) {
                PHPickerRepresentable(selectedImages: $selectedImages)
            }
            #endif
        }
    }
}

#if os(iOS)
// Helper struct for displaying UIImagePickerController in SwiftUI
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Environment(\.presentationMode) var presentationMode
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        // Not needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImages.append(originalImage)
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// PHPicker for multiple photo selection
struct PHPickerRepresentable: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PHPickerRepresentable>) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 0 // 0 means no limit
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<PHPickerRepresentable>) {
        // Not needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PHPickerRepresentable
        
        init(_ parent: PHPickerRepresentable) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.selectedImages.append(image)
                        }
                    }
                }
            }
        }
    }
}
#endif
=======

    var body: some View {
        HStack(alignment: .top) {
            TextField("Empty Input Prompt", text: $input, axis: .vertical)
                .scrollContentBackground(.hidden)
                .multilineTextAlignment(.leading)
                .lineLimit(10)
                .foregroundColor(Color("TextColor"))
                .font(.body())
                .focused($isTextEditorFocused)
                .onChange(of: isTextEditorFocused) { _, isFocused in
                    if !isFocused {
                        hideKeyboard()
                    }
                }
                .disabled(isInputDisabled)
                .opacity(isInputDisabled ? 0.6 : 1)
                .padding(12)

            ZStack {
                if isGenerating && !stopSubmitted {
                    Button(action: stop) {
                        Image("StopIcon")
                    }
                } else {
                    Button(action: respond) {
                        Image("SendIcon")
                    }
                    .disabled(!hasValidInput)
                    .opacity(hasValidInput ? 1 : 0.5)

                }
            }
            .onTapGesture {
                isTextEditorFocused = false
            }
            .font(.system(size: 24))
            .frame(width: 40, height: 40)
            .padding(.top, 4)
            .padding(.trailing, 4)

        }
        .padding([.leading, .trailing], 8)
        .frame(maxWidth: .infinity)
        .frame(minHeight: UIDevice.current.userInterfaceIdiom == .pad ? 80 : 40)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color("Surface"))
                .foregroundStyle(.thinMaterial)
        )
    }
}
>>>>>>> 800cefc0 (Initial commit- Research was already conducted for more info refer to the research structure file)

#Preview {
    @FocusState var isTextEditorFocused: Bool

    MessageInputView(
        input: .constant("Message"),
        isGenerating: .constant(false),
        stopSubmitted: .constant(false),
        isTextEditorFocused: $isTextEditorFocused,
        isInputDisabled: false,
        hasValidInput: true,
        respond: {
            print("Send")
        },
        stop: {
            print("Stop")
        }
    )
    .preferredColorScheme(.dark)
}
