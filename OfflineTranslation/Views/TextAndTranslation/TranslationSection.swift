//
//  TranslationSection.swift
//  OfflineTranslation
//
//  Created by Rohan Sampath on 3/17/25.
//

import SwiftUI
import Translation

struct TranslationSection: View {
    let detectedLanguage: String
    let recognizedText: String
    let translationUIStyle: TranslationUIStyle
    let sourceLanguage: Locale.Language?
    let targetLanguage: Locale.Language?
    
    @State private var shouldShowTranslationView = false
    @State private var showTranslationSheet = false
    @State private var isTranslationButtonDisabled = false

    private let dividerWidth: CGFloat = 50 // Space for button & divider

    var body: some View {
        VStack(alignment: .leading) {
            // Detected Language - Moved from RecognizedTextView
            DetectedLanguageView(detectedLanguage: detectedLanguage)
                .padding(.horizontal)
            
            GeometryReader { geometry in
                let textSectionWidth = (geometry.size.width - dividerWidth) / 2 // Adjusted width
                
                HStack(spacing: 0) {
                    // Left side - Original Text
                    VStack(alignment: .leading) {
                        RecognizedTextView(recognizedText: recognizedText)
                    }
                    .frame(width: textSectionWidth)

                    // Center - Vertical Divider and Translate Button
                    VStack {
                        // Translate Button centered horizontally
                        TranslateButtonView(
                            isDisabled: isTranslationButtonDisabled,
                            action: {
                                if (!recognizedText.isEmpty) {
                                    if translationUIStyle == .inlineDisplay,
                                       let sourceLang = sourceLanguage, 
                                       let targetLang = targetLanguage 
                                       {
                                        shouldShowTranslationView = true
                                        print("Translation initiated with source language: \(sourceLang.languageCode ?? "Not Set")")
                                        print("Target language: \(targetLang.languageCode ?? "Not Set")")
                                    } else if translationUIStyle == .modalSheet {
                                        showTranslationSheet = true
                                    }
                                }
                            }
                        )
                        .padding(.bottom, 15) // Space below button
                        .frame(maxWidth: .infinity, alignment: .center)

                        // Full-height divider
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 1)
                            .frame(maxHeight: .infinity)
                    }
                    .frame(width: dividerWidth) // Set explicit width for this section

                    // Right side - Translation
                    VStack {
                        if shouldShowTranslationView {
                            TranslationView(
                                sourceText: recognizedText,
                                sourceLanguage: sourceLanguage,
                                targetLanguage: targetLanguage
                            )
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        } else {
                            Spacer()
                        }
                    }
                    .frame(width: textSectionWidth) // Match left side
                }
            }

        }
        .if(translationUIStyle == .modalSheet) { view in
            view.translationPresentation(isPresented: $showTranslationSheet, text: recognizedText)
        }
        .onAppear {
            print("In Translation Section")
            print("Recognized Text: \(recognizedText)")
        }
        .onChange(of: sourceLanguage) {
            shouldShowTranslationView = false
        }
        .onChange(of: targetLanguage) {
            shouldShowTranslationView = false
        }
        .onChange(of: recognizedText) {
            shouldShowTranslationView = false
        }
    }
}
