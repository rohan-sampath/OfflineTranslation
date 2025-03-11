//
//  TranslationManager.swift
//  OfflineTranslation
//

import Foundation
import Translation
import SwiftUI

class TranslationManager: ObservableObject {
    @Published var translatedText: String = ""
    @Published var isTranslating: Bool = false
    @Published var translationError: String? = nil
    @Published var sourceLanguage: String = ""
    @Published var targetLanguage: String = "en"
    
    // Configuration for the translation task
    @Published var translationConfiguration: TranslationSession.Configuration? = nil
    
    func translateText(_ text: String) {
        guard !text.isEmpty else {
            // Update on main thread
            DispatchQueue.main.async {
                self.translationError = "No text to translate"
            }
            return
        }
        
        // Reset state - on main thread
        DispatchQueue.main.async {
            self.isTranslating = true
            self.translationError = nil
            self.translatedText = ""
        }
        
        // Cancel any existing translation
        translationConfiguration?.invalidate()
        
        print("Starting translation process for text: \(text.prefix(50))...")
        
        // Create a new configuration - this will trigger the translationTask modifier
        translationConfiguration = .init()
        
        print("Translation configuration created. Using Apple's Translation API (Offline)")
    }
    
    func cancelTranslation() {
        translationConfiguration?.invalidate()
        translationConfiguration = nil
        
        // Update on main thread
        DispatchQueue.main.async {
            self.isTranslating = false
        }
        
        print("Translation cancelled")
    }
    
    /// Updates the translation results on the main thread
    /// - Parameters:
    ///   - text: The translated text result
    /// This method is called from the translation task in ContentView after receiving results
    /// from the Translation API. It safely updates the UI state on the main thread.
    func updateTranslationResult(text: String) {
        DispatchQueue.main.async {
            self.translatedText = text
            self.isTranslating = false
            
            print("Translation completed: \(self.targetLanguage)")
            print("Translated text: \(text.prefix(50))...")
        }
    }
    
    /// Updates the translation error state on the main thread
    /// - Parameter error: The error that occurred during translation
    /// This method is called from the translation task in ContentView when an error occurs
    /// during the translation process.
    func updateTranslationError(_ error: Error) {
        DispatchQueue.main.async {
            self.translationError = error.localizedDescription
            self.isTranslating = false
            
            print("Translation error: \(error.localizedDescription)")
        }
    }
} 