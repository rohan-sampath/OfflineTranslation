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
        VStack {
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
                TranslationView(
                    sourceText: recognizedText,
                    sourceLanguage: getLocaleLanguage(from: sourceLanguage),
                    targetLanguage: getLocaleLanguage(from: targetLanguage)
                )
            }
        }
        .if(translationUIStyle == .modalSheet) { view in
                view.translationPresentation(isPresented: $showTranslationSheet, text: recognizedText)
        }
    }

    private func getLocaleLanguage(from languageCode: String) -> Locale.Language? {
        return !languageCode.isEmpty && languageCode != "detect"
            ? Locale.Language(identifier: languageCode.lowercased())
            : nil
    }
}
