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
    @State private var recognizedText: String = ""  // Stores extracted text
    @State private var detectedLanguage: String = "Unknown" // Stores detected language
    @State private var showTranslationSheet = false // Controls the translation sheet
    @State private var isPickerPresented = false
    @State private var isSettingsPresented = false
    
    @AppStorage("translationUIStyle") private var translationUIStyle = TranslationUIStyle.modalSheet
    
    // Add the translation manager
    @StateObject private var translationManager = TranslationManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    if let image = selectedImage {
                        ZStack(alignment: .bottomTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: UIScreen.main.bounds.height * 0.50) // Maximum 50% of screen height
                                .frame(maxWidth: .infinity, alignment: .center) // Explicitly set center alignment
                                .padding(.horizontal, 0) // No horizontal padding
                            
                            // Small photo icon button in bottom right
                            Button(action: {
                                isPickerPresented = true
                            }) {
                                Image(systemName: "photo")
                                    .font(.system(size: 22))
                                    .padding(12)
                                    .background(Color.blue.opacity(0.8))
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                            .padding(12) // Reduced padding
                        }
                        
                        // Display language and text information
                        VStack(alignment: .leading, spacing: 16) {
                            Text("**Language:** \(detectedLanguage)")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            // Show translate button only if there is recognized text AND using modal sheet style
                            if !recognizedText.isEmpty && translationUIStyle == .modalSheet {
                                Button(action: {
                                    showTranslationSheet = true
                                }) {
                                    Text("Translate")
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.blue.opacity(0.7))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .padding(.vertical, 8)
                            }
                            
                            // Always show the original text if available
                            if !recognizedText.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("**Original Text:**")
                                        .font(.headline)
                                    
                                    Text(recognizedText)
                                        .padding(.horizontal)
                                }
                            }
                            
                            // Show inline translation if that style is selected and we have translated text
                            if translationUIStyle == .inlineDisplay && !translationManager.translatedText.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("**Translation:**")
                                        .font(.headline)
                                    
                                    Text(translationManager.translatedText)
                                        .padding(.horizontal)
                                }
                            }
                            
                            // Show translation status or error if applicable
                            if translationUIStyle == .inlineDisplay && translationManager.isTranslating {
                                HStack {
                                    Text("Translating...")
                                    ProgressView()
                                }
                            } else if translationUIStyle == .inlineDisplay && translationManager.translationError != nil {
                                Text("Translation error: \(translationManager.translationError!)")
                                    .foregroundColor(.red)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    } else {
                        VStack {
                            Text("Select an Image")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.vertical, 100)
                            
                            Button("Choose Image") {
                                isPickerPresented = true
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.vertical) // Keep vertical padding only
            }
            .navigationTitle("Offline Translation")
            .navigationBarTitleDisplayMode(.inline) // Centers the title
            .toolbar {
                Button {
                    isSettingsPresented = true
                } label: {
                    Image(systemName: "gear")
                }
            }
            .sheet(isPresented: $isPickerPresented) {
                PhotoPicker(selectedImage: $selectedImage, recognizedText: $recognizedText, detectedLanguage: $detectedLanguage, onTextRecognized: { text, language in
                    // Reset translation state
                    translationManager.cancelTranslation()
                    
                    // If inline display is selected and we have text, automatically translate
                    if translationUIStyle == .inlineDisplay && !text.isEmpty && language != "Unknown" {
                        translationManager.translateText(text)
                    }
                })
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView()
            }
            // Conditionally apply the translation presentation modifier only for modal sheet style
            .if(translationUIStyle == .modalSheet) { view in
                view.translationPresentation(isPresented: $showTranslationSheet, text: recognizedText)
            }
    
            // Apply translationTask only if using inlineDisplay style
            .if(translationUIStyle == .inlineDisplay) { view in
                view.translationTask(translationManager.translationConfiguration) { session in
                    do {
                        print("Translating text from \(detectedLanguage) to English. Text to be translated: \(recognizedText.prefix(50))...")
                        
                        let response = try await session.translate(recognizedText)
                        
                        translationManager.updateTranslationResult(
                            text: response.targetText
                        )
                    } catch {
                        translationManager.updateTranslationError(error)
                    }
                }
            }
            .onChange(of: translationUIStyle) { oldValue, newValue in
                if newValue == .inlineDisplay && !recognizedText.isEmpty && detectedLanguage != "Unknown" {
                    // Automatically translate when switching to inline display
                    translationManager.translateText(recognizedText)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
