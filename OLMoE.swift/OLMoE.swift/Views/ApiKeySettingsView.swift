import SwiftUI

struct ApiKeySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey: String = ""
    @AppStorage("customApiKey") private var storedApiKey: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("API Key Settings")) {
                    SecureField("Enter API Key", text: $apiKey)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    if !storedApiKey.isEmpty {
                        Text("API Key is currently set")
                            .foregroundColor(.green)
                    }
                }
                
                Section {
                    Button("Save") {
                        storedApiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
                        dismiss()
                    }
                    .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    if !storedApiKey.isEmpty {
                        Button("Clear API Key") {
                            storedApiKey = ""
                            apiKey = ""
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("API Key")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                apiKey = storedApiKey
            }
        }
    }
}

#Preview {
    ApiKeySettingsView()
} 