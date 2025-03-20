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
    @State private var isPickerPresented: Bool = false
    @State private var isSettingsPresented: Bool = false
    @State private var isSourceLanguageToBeDetected: Bool = true
    
    @State private var sourceLanguage: Locale.Language? 
    @State private var targetLanguage: Locale.Language?
    @State private var availableLanguages: [AvailableLanguage] = []
    @State private var isLoadingLanguages: Bool = true
    
    @AppStorage("translationUIStyle") private var translationUIStyle = TranslationUIStyle.modalSheet
    
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
                            isSourceLanguageToBeDetected: $isSourceLanguageToBeDetected,
                            sourceLanguage: $sourceLanguage,
                            targetLanguage: $targetLanguage,
                            detectedLanguage: detectedLanguage,
                            availableLanguages: availableLanguages,
                            isImageSelected: isImageSelected
                        )
                        .padding(.vertical)
                    }
                    
                    if selectedImage != nil {
                        TranslationSection(
                            detectedLanguage: detectedLanguage, 
                            recognizedText: recognizedText, 
                            translationUIStyle: translationUIStyle, 
                            sourceLanguage: sourceLanguage, 
                            targetLanguage: targetLanguage, 
                            isSourceLanguageToBeDetected: isSourceLanguageToBeDetected
                        )
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
                    } else {
                        detectedLanguage = language
                        print("The new detected language is \(detectedLanguage)")
                    }
                }
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView()
            }
            .withSupportedLanguages(
                availableLanguages: $availableLanguages,
                isLoading: $isLoadingLanguages
            )
        }
    }
    }
