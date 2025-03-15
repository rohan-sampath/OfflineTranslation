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
    @State private var isLoadingLanguages = true
    
    @AppStorage("translationUIStyle") private var translationUIStyle = TranslationUIStyle.modalSheet
    
    @StateObject private var translationManager = TranslationManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ImagePickerView(selectedImage: $selectedImage, isPickerPresented: $isPickerPresented, isImageSelected: $isImageSelected)
                    
                    // Language pair view - always visible
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
                            translateAction: { showTranslationSheet = true }
                        )
                        
                        // TranslationView(
                        //     translationManager: translationManager,
                        //     translationUIStyle: translationUIStyle
                        // )
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
                        print ("IS EMPTY")
                        detectedLanguage = "No Text Detected"
                    } else {
                        detectedLanguage = language
                    }
                    print("The new detected language is \(detectedLanguage)")
                    //translationManager.cancelTranslation()
                    if translationUIStyle == .inlineDisplay && !text.isEmpty && language != "Unknown" {
                        print("🔄 ContentView: Starting inline translation")
                        translationManager.translateText(text)
                    }
                }
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView()
            }
            // .if(translationUIStyle == .modalSheet) { view in
            //     view.translationPresentation(isPresented: $showTranslationSheet, text: recognizedText)
            // }
            .onChange(of: translationUIStyle) { _, newValue in
                // if newValue == .inlineDisplay && !recognizedText.isEmpty && detectedLanguage != "Unknown" {
                //     translationManager.translateText(recognizedText)
                // }
            }
            .withSupportedLanguages(
                availableLanguages: $availableLanguages,
                isLoading: $isLoadingLanguages
            )
            .onChange(of: sourceLanguage) { _, _ in
                // updateTranslation()
            }
            .onChange(of: targetLanguage) { _, _ in
                // updateTranslation()
            }
            .onChange(of: detectedLanguage) { _, newLanguage in
                print("🔄 ContentView: onChange detected language change to '\(newLanguage)'")
                if sourceLanguage == "detect" && newLanguage != "Unknown" {
                    // updateTranslation()
                }
            }
        }
    }
    
    // private func updateTranslation() {
    //     print("🔄 ContentView: updateTranslation called - text length: \(recognizedText.count), language: '\(detectedLanguage)'")
    //     if !recognizedText.isEmpty && detectedLanguage != "Unknown" {
    //         translationManager.cancelTranslation()
    //         translationManager.translateText(recognizedText)
    //     }
    // }
}

#Preview {
    ContentView()
}
