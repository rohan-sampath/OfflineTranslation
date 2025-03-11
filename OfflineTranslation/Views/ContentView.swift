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
    @State private var selectedImage: UIImage? = nil
    @State private var recognizedText: String = ""
    @State private var detectedLanguage: String = "Unknown"
    @State private var showTranslationSheet = false
    @State private var isPickerPresented = false
    @State private var isSettingsPresented = false
    
    @AppStorage("translationUIStyle") private var translationUIStyle = TranslationUIStyle.modalSheet
    
    @StateObject private var translationManager = TranslationManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ImagePickerView(selectedImage: $selectedImage, isPickerPresented: $isPickerPresented)
                    
                    if let _ = selectedImage {
                        RecognizedTextView(
                            detectedLanguage: detectedLanguage,
                            recognizedText: recognizedText,
                            translationUIStyle: translationUIStyle,
                            translateAction: { showTranslationSheet = true }
                        )
                        
                        TranslationView(
                            translationManager: translationManager,
                            translationUIStyle: translationUIStyle
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
                    translationManager.cancelTranslation()
                    if translationUIStyle == .inlineDisplay && !text.isEmpty && language != "Unknown" {
                        translationManager.translateText(text)
                    }
                }
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView()
            }
            .if(translationUIStyle == .modalSheet) { view in
                view.translationPresentation(isPresented: $showTranslationSheet, text: recognizedText)
            }
            .onChange(of: translationUIStyle) { _, newValue in
                if newValue == .inlineDisplay && !recognizedText.isEmpty && detectedLanguage != "Unknown" {
                    translationManager.translateText(recognizedText)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
