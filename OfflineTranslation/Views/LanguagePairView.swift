import SwiftUI
import Translation

struct LanguagePairView: View {
    @Binding var sourceLanguage: String
    @Binding var targetLanguage: String
    var detectedLanguage: String
    var availableLanguages: [AvailableLanguage]
    var isImageSelected: Bool
    
    @AppStorage("defaultTargetLanguage") private var defaultTargetLanguage = "en_US"
    
    private let detectLanguageOption = "detect"
    
    var body: some View {
        HStack(spacing: 12) {
            // Source language picker
            Menu {
                Button {
                    sourceLanguage = detectLanguageOption
                } label: {
                    HStack {
                        Text("Detect Language")
                        if sourceLanguage == detectLanguageOption {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Divider()
                
                ForEach(availableLanguages, id: \.id) { language in
                    Button {
                        sourceLanguage = language.shortName()
                    } label: {
                        HStack {
                            Text(language.localizedName())
                            if sourceLanguage == language.shortName() {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    if sourceLanguage == detectLanguageOption {
                        if isImageSelected && detectedLanguage != "Unknown" && detectedLanguage != "No Text Detected" {
                            // Show detected language
                            let detectedLocalizedName = availableLanguages
                                .first(where: { $0.shortName() == detectedLanguage })?
                                .localizedName() ?? detectedLanguage
                            
                            Text("Detected - \(detectedLocalizedName)")
                                .lineLimit(2)
                        } else {
                            Text("Detect Language")
                        }
                    } else {
                        // Show selected language
                        let selectedLocalizedName = availableLanguages
                            .first(where: { $0.shortName() == sourceLanguage })?
                            .localizedName() ?? sourceLanguage
                        
                        Text(selectedLocalizedName)
                            .lineLimit(2)
                    }
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // Arrow between pickers
            Image(systemName: "arrow.right")
                .foregroundColor(.secondary)
            
            // Target language picker
            Menu {
                ForEach(availableLanguages, id: \.id) { language in
                    let isDisabled = sourceLanguage != detectLanguageOption && 
                                    sourceLanguage == language.shortName() ||
                                    (sourceLanguage == detectLanguageOption && 
                                     detectedLanguage != "Unknown" && 
                                     detectedLanguage == language.shortName())
                    
                    Button {
                        targetLanguage = language.shortName()
                    } label: {
                        HStack {
                            Text(language.localizedName())
                            if targetLanguage == language.shortName() {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .disabled(isDisabled)
                }
            } label: {
                HStack {
                    let selectedLocalizedName = availableLanguages
                        .first(where: { $0.shortName() == targetLanguage })?
                        .localizedName() ?? targetLanguage
                    
                    Text(selectedLocalizedName)
                        .lineLimit(2)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .onAppear {
            // Print the detectedLanguage value
            print("🔍 LanguagePairView: detectedLanguage is '\(detectedLanguage)'")
            
            // Set default target language if not already set
            if targetLanguage.isEmpty {
                targetLanguage = defaultTargetLanguage
            }
            
            // Set source language to detect by default
            if sourceLanguage.isEmpty {
                sourceLanguage = detectLanguageOption
            }
        }
    }
}