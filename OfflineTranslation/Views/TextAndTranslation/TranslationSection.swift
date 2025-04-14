//
//  TranslationSection.swift
//  OfflineTranslation
//
//  Created by Rohan Sampath on 3/17/25.
//

import SwiftUI
import Translation
import Foundation

struct TranslationSection: View {
    let detectedLanguage: String
    let recognizedText: String
    let translationUIStyle: TranslationUIStyle
    let sourceLanguage: Locale.Language?
    let targetLanguage: Locale.Language?
    let isSourceLanguageToBeDetected: Bool
    
    @State private var shouldShowTranslationView = false
    @State private var showTranslationSheet = false
    @State private var isTranslationButtonDisabled = false
    @State private var errorMessage = ""

    private let dividerWidth: CGFloat = 50 // Space for button & divider

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Detected Language - Moved from RecognizedTextView
                DetectedLanguageView(
                    isTextDetected: !recognizedText.isEmpty,
                    detectedLanguage: detectedLanguage,
                    sourceLanguage: Locale.current.localizedString(forLanguageCode: sourceLanguage?.languageCode?.identifier ?? "") ?? "",
                    isSourceLanguageToBeDetected: isSourceLanguageToBeDetected
                )
                .padding(.horizontal)
                .padding(.top, 8)
                
                GeometryReader { geometry in
                    let textSectionWidth = (geometry.size.width - dividerWidth) / 2
                    
                    HStack(spacing: 0) {
                        // Left side - Original Text
                        VStack(alignment: .leading) {
                            RecognizedTextView(recognizedText: recognizedText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(width: textSectionWidth, alignment: .top)

                        // Center - Vertical Divider and Translate Button
                        VStack(spacing: 0) {
                            // Translate Button at the top
                            if !recognizedText.isEmpty {
                                TranslateButtonView(
                                    isDisabled: isTranslationButtonDisabled,
                                    action: {
                                        if (!recognizedText.isEmpty) {
                                            if translationUIStyle == .inlineDisplay,
                                               let sourceLang = sourceLanguage, 
                                               let targetLang = targetLanguage 
                                               {
                                                shouldShowTranslationView = true
                                                print("✅ [TranslationSection] shouldShowTranslationView set to TRUE - Translation initiated")
                                                print("Translation initiated with source language: \(sourceLang.languageCode ?? "Not Set")")
                                                print("Target language: \(targetLang.languageCode ?? "Not Set")")
                                            } else if translationUIStyle == .modalSheet {
                                                showTranslationSheet = true
                                            }
                                        }
                                    },
                                    errorMessage: errorMessage
                                )
                                .padding(.bottom, 15)
                                .frame(maxWidth: .infinity, alignment: .center)
                            }

                            // Full-height divider
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 1)
                                .frame(maxHeight: .infinity)
                            
                            Spacer() // Push everything up to the top
                        }
                        .frame(width: dividerWidth, alignment: .top) // Align to top

                        // Right side - Translation
                        VStack(alignment: .leading) {
                            if shouldShowTranslationView {
                                TranslationView(
                                    sourceText: recognizedText,
                                    sourceLanguage: sourceLanguage,
                                    targetLanguage: targetLanguage
                                )
                                .fixedSize(horizontal: false, vertical: true)
                            } else {
                                Spacer()
                            }
                        }
                        .frame(width: textSectionWidth, alignment: .top)
                    }
                }
                .frame(minHeight: 400) // Ensure enough space for content
                .padding(.bottom, 40) // Extra padding at the bottom
            }
        }
        .if(translationUIStyle == .modalSheet) { view in
            view.translationPresentation(isPresented: $showTranslationSheet, text: recognizedText)
        }
        .onAppear {
            print("In Translation Section")
            print("Recognized Text: \(recognizedText)")
            checkLanguages()
        }
        .onChange(of: sourceLanguage) {
            shouldShowTranslationView = false
            print("🔄 [TranslationSection] shouldShowTranslationView set to FALSE - sourceLanguage changed")
            checkLanguages()
        }
        .onChange(of: targetLanguage) {
            shouldShowTranslationView = false
            print("🔄 [TranslationSection] shouldShowTranslationView set to FALSE - targetLanguage changed")
            checkLanguages()
        }
        .onChange(of: recognizedText) {
            shouldShowTranslationView = false
            print("🔄 [TranslationSection] shouldShowTranslationView set to FALSE - recognizedText changed")
        }
    }
    
    private func checkLanguages() {
        // Check if source and target languages are the same and both are set
        if let source = sourceLanguage, 
           let target = targetLanguage,
           source.languageCode == target.languageCode {
            isTranslationButtonDisabled = true
            errorMessage = "Translation requires different source and target languages."
        } else {
            isTranslationButtonDisabled = false
            errorMessage = ""
        }
    }
}