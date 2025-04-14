import SwiftUI
import Translation
import Foundation

struct TranslationSection: View {
    let detectedLanguage: String
    let possibleLanguages: [String]
    let recognizedText: String
    let translationUIStyle: TranslationUIStyle
    let sourceLanguage: Locale.Language?
    let targetLanguage: Locale.Language?
    let isSourceLanguageToBeDetected: Bool
    let isDetectedLanguageSupported: Bool
    let unsupportedLanguageError: String
    
    @State private var shouldShowTranslationView = false
    @State private var showTranslationSheet = false
    @State private var isTranslationButtonDisabled = false
    @State private var errorMessage = ""
    @State private var showFullOriginalText = false
    @State private var showFullTranslationText = false
    @State private var needsExpandButton = false

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Header
                DetectedLanguageView(
                    isTextDetected: !recognizedText.isEmpty,
                    detectedLanguage: detectedLanguage,
                    possibleLanguages: possibleLanguages,
                    sourceLanguage: Locale.current.localizedString(forLanguageCode: sourceLanguage?.languageCode?.identifier ?? "") ?? "",
                    isSourceLanguageToBeDetected: isSourceLanguageToBeDetected
                )
                .padding(.horizontal)
                .padding(.top, 2)
                
                // Original Text Section - Only show if there's text
                if !recognizedText.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Original Text")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            // Check if we need expand button
                            let shouldShowExpandButton = recognizedText.components(separatedBy: "\n").count > 10 || recognizedText.count > 500
                            
                            Text(recognizedText)
                                .lineLimit(shouldShowExpandButton && !showFullOriginalText ? 10 : nil)
                                .padding(.horizontal)
                            
                            if shouldShowExpandButton {
                                Button(action: {
                                    showFullOriginalText.toggle()
                                }) {
                                    Text(showFullOriginalText ? "Show Less" : "Show More")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                                .padding(.horizontal)
                                .padding(.top, 2)
                                .onAppear {
                                    needsExpandButton = true
                                }
                            } else {
                                // If we don't need expand button for original text
                                Color.clear
                                    .frame(height: 0)
                                    .onAppear {
                                        needsExpandButton = false
                                    }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                    
                    // Translate Button
                    TranslateButtonView(
                        isDisabled: isTranslationButtonDisabled,
                        action: {
                            if translationUIStyle == .inlineDisplay,
                               let _ = sourceLanguage,
                               let _ = targetLanguage {
                                shouldShowTranslationView = true
                            } else if translationUIStyle == .modalSheet {
                                showTranslationSheet = true
                            }
                        },
                        errorMessage: errorMessage
                    )
                    .padding(.vertical, 4)
                }
                
                // Translation Section
                if shouldShowTranslationView {
                    VStack(alignment: .leading, spacing: 4) {
                        // Translation title with language information
                        Text("Translation (from \(getLanguageName(sourceLanguage)) to \(getLanguageName(targetLanguage)))")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if let translationView = TranslationView(
                            sourceText: recognizedText,
                            sourceLanguage: sourceLanguage,
                            targetLanguage: targetLanguage
                        ) {
                            VStack(alignment: .leading, spacing: 4) {
                                translationView
                                    .lineLimit(needsExpandButton && !showFullTranslationText ? 10 : nil)
                                
                                // Only show expand button if needed for original text
                                if needsExpandButton {
                                    Button(action: {
                                        showFullTranslationText.toggle()
                                    }) {
                                        Text(showFullTranslationText ? "Show Less" : "Show More")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 2)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                }
                
                // Extra space at the bottom to prevent cutoff
                Spacer(minLength: 50)
            }
        }
        .if(translationUIStyle == .modalSheet) { view in
            view.translationPresentation(isPresented: $showTranslationSheet, text: recognizedText)
        }
        .onAppear {
            checkLanguages()
        }
        .onChange(of: sourceLanguage) {
            shouldShowTranslationView = false
            checkLanguages()
        }
        .onChange(of: targetLanguage) {
            shouldShowTranslationView = false
            checkLanguages()
        }
        .onChange(of: isDetectedLanguageSupported) {
            checkLanguages()
        }
        .onChange(of: unsupportedLanguageError) {
            checkLanguages()
        }
        .onChange(of: recognizedText) {
            shouldShowTranslationView = false
            showFullOriginalText = false
            showFullTranslationText = false
            
            // Check if we need expand button for the new text
            needsExpandButton = recognizedText.components(separatedBy: "\n").count > 10 || recognizedText.count > 500
        }
    }
    
    private func checkLanguages() {
        // First check if detected language is supported when in detect mode
        if isSourceLanguageToBeDetected && !isDetectedLanguageSupported && !unsupportedLanguageError.isEmpty {
            isTranslationButtonDisabled = true
            errorMessage = unsupportedLanguageError
            return
        }
        
        // Then check if source and target languages are the same
        if let source = sourceLanguage, 
           let target = targetLanguage,
           source.languageCode == target.languageCode {
            isTranslationButtonDisabled = true
            errorMessage = "Translation requires different source and target languages."
            return
        }
        
        // If source language is nil and we're in detect mode, disable translation
        if sourceLanguage == nil && isSourceLanguageToBeDetected {
            isTranslationButtonDisabled = true
            errorMessage = "Cannot translate: no source language detected."
            return
        }
        
        // If we get here, translation should be enabled
        isTranslationButtonDisabled = false
        errorMessage = ""
    }
    
    // Helper function to get language name
    private func getLanguageName(_ language: Locale.Language?) -> String {
        guard let language = language else { return "Unknown" }
        
        let locale = Locale.current
        if let languageName = locale.localizedString(forLanguageCode: language.languageCode?.identifier ?? "") {
            return languageName
        }
        
        return language.languageCode?.identifier ?? "Unknown"
    }
}
