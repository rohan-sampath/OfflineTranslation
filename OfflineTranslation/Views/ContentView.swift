//
//  ContentView.swift
//  OfflineTranslation
//
//  Created by Rohan Sampath on 2/28/25.
//

import SwiftUI
import PhotosUI
import Translation

struct ContentView: View {
    @State private var selectedImage: UIImage? = nil {
        didSet {
            isImageSelected = selectedImage != nil
        }
    }
    @State private var recognizedText: String = ""
    @State private var detectedLanguage: String = "Unknown"
    @State private var isImageSelected: Bool = false
    @State private var showTranslationSheet = false
    @State private var isPickerPresented = false
    @State private var isSettingsPresented = false
    
    @State private var sourceLanguage: String = "detect"
    @State private var targetLanguage: String = ""
    @State private var availableLanguages: [AvailableLanguage] = []
    @State private var isLoadingLanguages: Bool = true
    
    @AppStorage("translationUIStyle") private var translationUIStyle = TranslationUIStyle.modalSheet
    
    @State private var shouldShowTranslationView: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ImagePickerView(selectedImage: $selectedImage, isPickerPresented: $isPickerPresented, isImageSelected: $isImageSelected)
                    
                    if isLoadingLanguages {
                        ProgressView()
                            .padding()
                    } else {
                        LanguagePairView(
                            sourceLanguage: $sourceLanguage,
                            targetLanguage: $targetLanguage,
                            detectedLanguage: detectedLanguage,
                            availableLanguages: availableLanguages,
                            isImageSelected: isImageSelected
                        )
                        .padding(.vertical)
                    }
                    
                    if let _ = selectedImage {
                        RecognizedTextView(
                            detectedLanguage: detectedLanguage,
                            recognizedText: recognizedText,
                            translationUIStyle: translationUIStyle,
                            translateAction: {
                                if !sourceLanguage.isEmpty && !targetLanguage.isEmpty && !recognizedText.isEmpty && translationUIStyle == .inlineDisplay {
                                    shouldShowTranslationView = true
                                    print("TOUJOURS SOUMIS")
                                } 
                                else if translationUIStyle == .modalSheet {
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
                .padding(.vertical)
            }
            .navigationTitle("Offline Translation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                SettingsButtonView(isSettingsPresented: $isSettingsPresented)
            }
            .sheet(isPresented: $isPickerPresented) {
                PhotoPicker(selectedImage: $selectedImage, recognizedText: $recognizedText, detectedLanguage: $detectedLanguage) { text, language in
                    print("📲 ContentView: PhotoPicker callback received - text length: \(text.count), language: '\(language)'")
                    if text.isEmpty {
                        print("IS EMPTY")
                        detectedLanguage = "No Text Detected"
                    } else {
                        detectedLanguage = language
                    }
                    print("The new detected language is \(detectedLanguage)")
                }
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView()
            }
            .if(translationUIStyle == .modalSheet) { view in
                view.translationPresentation(isPresented: $showTranslationSheet, text: recognizedText)
            }
            .withSupportedLanguages(
                availableLanguages: $availableLanguages,
                isLoading: $isLoadingLanguages
            )
            .onChange(of: sourceLanguage) { _, _ in
                shouldShowTranslationView = !sourceLanguage.isEmpty && !targetLanguage.isEmpty
            }
            .onChange(of: targetLanguage) { _, _ in
                shouldShowTranslationView = !sourceLanguage.isEmpty && !targetLanguage.isEmpty
            }
            .onChange(of: detectedLanguage) { _, newLanguage in
                print("🔄 ContentView: onChange detected language change to '\(newLanguage)'")
                shouldShowTranslationView = !sourceLanguage.isEmpty && !targetLanguage.isEmpty
            }
        }
    }
    
    // Helper function to convert string language code to Locale.Language
    private func getLocaleLanguage(from languageCode: String) -> Locale.Language? {
        return !languageCode.isEmpty && languageCode != "detect"
            ? Locale.Language(identifier: languageCode.lowercased())
            : nil
    }
}

#Preview {
    ContentView()
}
