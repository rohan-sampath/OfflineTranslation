import SwiftUI
import Translation

struct LanguagePairView: View {
    @Binding var isSourceLanguageToBeDetected: Bool
    @Binding var sourceLanguage: Locale.Language?
    @Binding var targetLanguage: Locale.Language?
    @Binding var isDetectedLanguageSupported: Bool
    @Binding var unsupportedLanguageError: String
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
                    // Reset sourceLanguage when switching to "Detect Language" mode
                    if detectedLanguage == "Unknown" || !isImageSelected {
                        sourceLanguage = nil
                        isDetectedLanguageSupported = true
                        unsupportedLanguageError = ""
                    } else {
                        // Set sourceLanguage to the detected language
                        let matchedLanguage = AvailableLanguage.findMatchingLanguage(
                            availableLanguages: availableLanguages,
                            inputLanguage: detectedLanguage
                        )
                        sourceLanguage = matchedLanguage
                        // Check if the detected language is supported
                        isDetectedLanguageSupported = matchedLanguage != nil
                        if !isDetectedLanguageSupported {
                            unsupportedLanguageError = "Detected language '\(detectedLanguage)' is not supported by Apple Translate"
                        } else {
                            unsupportedLanguageError = ""
                        }
                    }
                    print(" LanguagePairView: isSourceLanguageToBeDetected set to true. sourceLanguage: \(sourceLanguage?.languageCode ?? "nil")")
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
                        sourceLanguage = language.locale
                        isSourceLanguageToBeDetected = false
                        isDetectedLanguageSupported = true
                        unsupportedLanguageError = ""
                        print("LanguagePairView:  Source language changed to: \(language.localizedName()) (\(language.shortName()))")
                    } label: {
                        HStack {
                            Text(language.localizedName())
                            if let source = sourceLanguage {
                                if compareLanguages(source, language.locale) && !isSourceLanguageToBeDetected {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    if isSourceLanguageToBeDetected {
                        if isImageSelected && detectedLanguage != "Unknown" {
                            // Show detected language
                            let detectedAvailableLanguage = availableLanguages
                                .first(where: { languageShortNameMatches($0.shortName(), detectedLanguage) })
                            
                            let detectedLocalizedName = detectedAvailableLanguage?.localizedName() ?? detectedLanguage
                            
                            Text("Detected - \(detectedLocalizedName)")
                                .lineLimit(2)
                        } else {
                            Text("Detect Language")
                        }
                    } else {
                        // Show selected language
                        if let source = sourceLanguage {
                            let selectedAvailableLanguage = availableLanguages
                                .first(where: { compareLanguages(source, $0.locale) })
                            
                            let selectedLocalizedName = selectedAvailableLanguage?.localizedName() ?? "Unknown"
                            
                            Text(selectedLocalizedName)
                                .lineLimit(2)
                        } else {
                            Text("Select Language")
                                .lineLimit(2)
                        }
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
                    let isDisabled = sourceLanguage?.languageCode == language.locale.languageCode
                    
                    Button {
                        targetLanguage = language.locale
                        print("LanguagePairView:  Target language changed to: \(language.localizedName()) (\(language.shortName()))")
                    } label: {
                        HStack {
                            Text(language.localizedName())
                            if let target = targetLanguage, compareLanguages(target, language.locale) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .disabled(isDisabled)
                }
            } label: {
                HStack {
                    if let target = targetLanguage {
                        let selectedAvailableLanguage = availableLanguages
                            .first(where: { compareLanguages(target, $0.locale) })
                        
                        let selectedLocalizedName = selectedAvailableLanguage?.localizedName() ?? "Unknown"
                        
                        Text(selectedLocalizedName)
                            .lineLimit(2)
                    } else {
                        Text("Select Language")
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
        }
        .padding(.horizontal)
          .onChange(of: detectedLanguage) {
            print(" LanguagePairView: Detected language changed to: \(detectedLanguage)")
            
            // Reset sourceLanguage when detectedLanguage is "Unknown" and in detect mode
            if detectedLanguage == "Unknown" && isSourceLanguageToBeDetected {
                sourceLanguage = nil
                isDetectedLanguageSupported = true
                unsupportedLanguageError = ""
                print(" LanguagePairView: Reset sourceLanguage to nil because detectedLanguage is Unknown")
                return
            }
            
            // Use findMatchingLanguage when source language is set to be detected
            if isSourceLanguageToBeDetected && detectedLanguage != "Unknown" {
                // Find the matching language code using our function
                let matchedLanguage = AvailableLanguage.findMatchingLanguage(
                    availableLanguages: availableLanguages,
                    inputLanguage: detectedLanguage
                )
                print("Matched Language: \(matchedLanguage?.languageCode ?? "nil")")
                
                // Check if the detected language is supported
                isDetectedLanguageSupported = matchedLanguage != nil
                if !isDetectedLanguageSupported {
                    unsupportedLanguageError = "Detected language '\(detectedLanguage)' is not supported by Apple Translate"
                    print(" LanguagePairView: Detected language \(detectedLanguage) is not supported")
                } else {
                    unsupportedLanguageError = ""
                }
                
                // Update the source language if we found a match
                if matchedLanguage != nil {
                    sourceLanguage = matchedLanguage
                    print(" LanguagePairView: Matched detected language \(detectedLanguage) to: \(matchedLanguage?.languageCode ?? "nil")")
                }
                else {
                    sourceLanguage = nil
                    print(" LanguagePairView: Detected language \(detectedLanguage) not found in available languages.")
                }
            }
        }
        .onChange(of: sourceLanguage) {
            print(" LanguagePairView: Source language changed to: \(sourceLanguage?.languageCode ?? "nil")")
        }
        .onChange(of: targetLanguage) {
            print(" LanguagePairView: Target language changed to: \(targetLanguage?.languageCode ?? "nil")")
        }
        .onChange(of: isImageSelected) { 
            // Reset sourceLanguage when there's no image and in detect mode
            if !isImageSelected && isSourceLanguageToBeDetected {
                sourceLanguage = nil
                isDetectedLanguageSupported = true
                unsupportedLanguageError = ""
                print(" LanguagePairView: Reset sourceLanguage to nil because no image is selected")
            }
        }
        .onAppear {
            // Set default target language if not already set
            if targetLanguage == nil {
                targetLanguage = Locale.Language(identifier: defaultTargetLanguage)
                print(" LanguagePairView: Target language set to default: \(defaultTargetLanguage)")
            }
            
            // Reset sourceLanguage if no image is selected and in detect mode
            if !isImageSelected && isSourceLanguageToBeDetected {
                sourceLanguage = nil
                isDetectedLanguageSupported = true
                unsupportedLanguageError = ""
                print(" LanguagePairView: Reset sourceLanguage to nil on appear because no image is selected")
            }
        }
    }
    
    // Helper function to properly compare two Locale.Language objects
    private func compareLanguages(_ language1: Locale.Language, _ language2: Locale.Language) -> Bool {
        return language1.languageCode == language2.languageCode && 
               language1.region == language2.region
    }
    
    // Helper function to compare a language shortName with a string code
    private func languageShortNameMatches(_ shortName: String, _ code: String) -> Bool {
        return shortName == code
    }
}