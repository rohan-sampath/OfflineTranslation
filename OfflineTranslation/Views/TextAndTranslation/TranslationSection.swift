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
    let sourceLanguage: String
    let targetLanguage: String
    
    @State private var shouldShowTranslationView = false
    @State private var showTranslationSheet = false

    var body: some View {
        VStack(spacing: 20) {
            RecognizedTextView(
                detectedLanguage: detectedLanguage,
                recognizedText: recognizedText,
                translationUIStyle: translationUIStyle,
                translateAction: {
                    if !sourceLanguage.isEmpty && !targetLanguage.isEmpty && !recognizedText.isEmpty && translationUIStyle == .inlineDisplay {
                        shouldShowTranslationView = true
                        print ("TOUJOURS SOUMIS")
                    } else if translationUIStyle == .modalSheet {
                        showTranslationSheet = true
                    }
                }
            )

            if shouldShowTranslationView {
                Divider()
                TranslationView(
                    sourceText: recognizedText,
                    sourceLanguage: getLocaleLanguage(from: sourceLanguage),
                    targetLanguage: getLocaleLanguage(from: targetLanguage)
                )
                .padding(.vertical)
            }
        }
        .if(translationUIStyle == .modalSheet) { view in
                view.translationPresentation(isPresented: $showTranslationSheet, text: recognizedText)
        }.onAppear {
            print("In Translation Section")
            print("Source Language: \(sourceLanguage)", "Target Language: \(targetLanguage)", "Recognized Text: \(recognizedText)")
        }
    }
    

    private func getLocaleLanguage(from languageCode: String) -> Locale.Language? {
        return !languageCode.isEmpty && languageCode != "detect"
            ? Locale.Language(identifier: languageCode.lowercased())
            : nil
    }
}
