import Foundation
import Translation
import SwiftUI

/// Utility functions for handling languages in the app
class LanguageUtilities {
    
    /// Loads all supported languages for translation
    /// - Returns: A sorted array of AvailableLanguage objects
    static func loadSupportedLanguages() async -> [AvailableLanguage] {
        let availability = LanguageAvailability()
        let supportedLanguages = await availability.supportedLanguages
        
        // Convert to AvailableLanguage objects and sort alphabetically
        return supportedLanguages.map { AvailableLanguage(locale: $0) }
            .sorted()
    }
}

/// A view modifier that loads supported languages and provides them to the view
struct WithSupportedLanguages: ViewModifier {
    @Binding var availableLanguages: [AvailableLanguage]
    @Binding var isLoading: Bool
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                Task {
                    isLoading = true
                    availableLanguages = await LanguageUtilities.loadSupportedLanguages()
                    isLoading = false
                }
            }
    }
}

extension View {
    /// Loads supported languages and provides them to the view
    /// - Parameters:
    ///   - availableLanguages: Binding to store the loaded languages
    ///   - isLoading: Binding to track loading state
    /// - Returns: A view with language loading capability
    func withSupportedLanguages(
        availableLanguages: Binding<[AvailableLanguage]>,
        isLoading: Binding<Bool>
    ) -> some View {
        self.modifier(WithSupportedLanguages(
            availableLanguages: availableLanguages,
            isLoading: isLoading
        ))
    }
} 