import SwiftUI
import Translation

struct LanguagePairView: View {
    @Binding var isSourceLanguageToBeDetected: Bool
    @Binding var sourceLanguage: Locale.Language?
    @Binding var targetLanguage: Locale.Language?
    var detectedLanguage: String
    var availableLanguages: [AvailableLanguage]
    var isImageSelected: Bool
    
    @AppStorage("defaultTargetLanguage") private var defaultTargetLanguage: String = "en-US"
         
    var body: some View {
        HStack(spacing: 12) {
            // Source language picker
            Menu {
                Button {
                    isSourceLanguageToBeDetected = true
                    print("🔤 LanguagePairView: isSourceLanguageToBeDetected set to true.")
                } label: {
                    HStack {
                        Text("Detect Language")
                        if isSourceLanguageToBeDetected {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Divider()
                
                ForEach(availableLanguages, id: \.id) { language in
                    Button {
                        sourceLanguage = language
                        isSourceLanguageToBeDetected = false
                        print("LanguagePairView: 🔤 Source language changed to: \(language.localizedName()) (\(language.shortName()))")
                    } label: {
                        HStack {
                            Text(language.localizedName())
                            if sourceLanguage?.shortName() == language.shortName() && !isSourceLanguageToBeDetected {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    if isSourceLanguageToBeDetected {
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
                    let isDisabled = sourceLanguage?.languageNameOnly() == language.languageNameOnly()
                    
                    Button {
                        targetLanguage = language
                        print("LanguagePairView: 🎯 Target language changed to: \(language.localizedName()) (\(language.shortName()))")
                    } label: {
                        HStack {
                            Text(language.localizedName())
                            if targetLanguage?.shortName() == language.shortName() {
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
          .onChange(of: detectedLanguage) {
            print("🔤 LanguagePairView: Detected language changed to: \(detectedLanguage)")
            
            // Use findMatchingLanguage when source language is set to be detected
            if isSourceLanguageToBeDetected && detectedLanguage != "Unknown" && detectedLanguage != "No Text Detected" {
                // Find the matching language code using our function
                let matchedLanguage = AvailableLanguage.findMatchingLanguage(
                    availableLanguages: availableLanguages,
                    inputLanguage: detectedLanguage
                )
                print ("Matched Language: \(matchedLanguage)")
                // Update the source language if we found a match
                if matchedLanguage != nil {
                    sourceLanguage = matchedLanguage
                    print("🔤 LanguagePairView: Matched detected language \(detectedLanguage) to: \(matchedLanguage)")
                }
                else {
                    sourceLanguage = nil
                    print("🔤 LanguagePairView: Detected language \(detectedLanguage) not found in available languages.")
                }
            }
        }
        .onChange(of: sourceLanguage) {
            print("🔤 LanguagePairView: Source language changed to: \(sourceLanguage)")
        }
        .onChange(of: targetLanguage) {
            print("🎯 LanguagePairView: Target language changed to: \(targetLanguage)")
        }
        .onAppear {
            // Set default target language if not already set
            if targetLanguage.isEmpty {
                targetLanguage = LanguageUtilities.getLocaleLanguage(from: defaultTargetLanguage)
                print("🎯 LanguagePairView: Target language set to default: \(defaultTargetLanguage)")
            }
           
        }
    }
}