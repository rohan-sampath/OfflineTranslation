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

    private let dividerWidth: CGFloat = 50

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DetectedLanguageView(
                    isTextDetected: !recognizedText.isEmpty,
                    detectedLanguage: detectedLanguage,
                    sourceLanguage: Locale.current.localizedString(forLanguageCode: sourceLanguage?.languageCode?.identifier ?? "") ?? "",
                    isSourceLanguageToBeDetected: isSourceLanguageToBeDetected
                )
                .padding(.horizontal)

                GeometryReader { geometry in
                    let textSectionWidth = (geometry.size.width - dividerWidth) / 2

                    HStack(spacing: 0) {
                        VStack(alignment: .leading) {
                            RecognizedTextView(recognizedText: recognizedText)
                                .padding(.trailing, 4)
                        }
                        .frame(width: textSectionWidth, alignment: .topLeading)

                        VStack(spacing: 0) {
                            if !recognizedText.isEmpty {
                                TranslateButtonView(
                                    isDisabled: isTranslationButtonDisabled,
                                    action: {
                                        if translationUIStyle == .inlineDisplay,
                                           let sourceLang = sourceLanguage,
                                           let targetLang = targetLanguage {
                                            shouldShowTranslationView = true
                                        } else if translationUIStyle == .modalSheet {
                                            showTranslationSheet = true
                                        }
                                    },
                                    errorMessage: errorMessage
                                )
                                .padding(.bottom, 15)
                                .frame(maxWidth: .infinity, alignment: .center)
                            }

                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 1)
                                .frame(maxHeight: .infinity)
                        }
                        .frame(width: dividerWidth)

                        VStack(alignment: .leading) {
                            if shouldShowTranslationView {
                                TranslationView(
                                    sourceText: recognizedText,
                                    sourceLanguage: sourceLanguage,
                                    targetLanguage: targetLanguage
                                )
                                .padding()
                            } else {
                                Spacer()
                            }
                        }
                        .frame(width: textSectionWidth, alignment: .topLeading)
                    }
                    .frame(height: geometry.size.height)
                }
                .frame(minHeight: 400) // ✅ Prevent collapse
            }
            .padding(.bottom)
        }
        .if(translationUIStyle == .modalSheet) { view in
            view.translationPresentation(isPresented: $showTranslationSheet, text: recognizedText)
        }
        .onAppear {
            checkLanguages()
        }
        .onChange(of: sourceLanguage) { _ in
            shouldShowTranslationView = false
            checkLanguages()
        }
        .onChange(of: targetLanguage) { _ in
            shouldShowTranslationView = false
            checkLanguages()
        }
        .onChange(of: recognizedText) { _ in
            shouldShowTranslationView = false
        }
    }

    private func checkLanguages() {
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