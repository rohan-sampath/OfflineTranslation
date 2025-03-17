//
//  TranslationSection.swift
//  OfflineTranslation
//
//  Created by Rohan Sampath on 3/17/25.
//

import SwiftUI

struct TranslationSection: View {
    let detectedLanguage: String
    let recognizedText: String
    let translationUIStyle: TranslationUIStyle
    @Binding var shouldShowTranslationView: Bool
    @Binding var showTranslationSheet: Bool
    let sourceLanguage: String
    let targetLanguage: String

    var body: some View {
        VStack {
            RecognizedTextView(
                detectedLanguage: detectedLanguage,
                recognizedText: recognizedText,
                translationUIStyle: translationUIStyle,
                translateAction: {
                    if !sourceLanguage.isEmpty && !targetLanguage.isEmpty && !recognizedText.isEmpty && translationUIStyle == .inlineDisplay {
                        shouldShowTranslationView = true
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
    }
}
