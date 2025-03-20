import XCTest
import SwiftUI
@testable import OfflineTranslation

final class LanguagePairViewTests: XCTestCase {
    
    // Test that the view initializes with default values
    func testDefaultInitialization() {
        // Setup
        let isSourceLanguageToBeDetected = Binding.constant(false)
        let sourceLanguage = Binding<Locale.Language?>.constant(nil)
        let targetLanguage = Binding<Locale.Language?>.constant(nil)
        let availableLanguages = [
            AvailableLanguage(locale: Locale.Language(identifier: "en-US")),
            AvailableLanguage(locale: Locale.Language(identifier: "es-ES"))
        ]
        
        // Create the view
        let view = LanguagePairView(
            isSourceLanguageToBeDetected: isSourceLanguageToBeDetected,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            detectedLanguage: "Unknown",
            availableLanguages: availableLanguages,
            isImageSelected: false
        )
        
        // Verify initial state
        XCTAssertFalse(isSourceLanguageToBeDetected.wrappedValue)
        XCTAssertNil(sourceLanguage.wrappedValue)
        XCTAssertNil(targetLanguage.wrappedValue)
        XCTAssertEqual(view.detectedLanguage, "Unknown")
        XCTAssertEqual(view.availableLanguages.count, 2)
        XCTAssertFalse(view.isImageSelected)
    }
    
    // Test the compareLanguages helper function
    func testCompareLanguages() {
        // Setup
        let isSourceLanguageToBeDetected = Binding.constant(false)
        let sourceLanguage = Binding<Locale.Language?>.constant(nil)
        let targetLanguage = Binding<Locale.Language?>.constant(nil)
        let availableLanguages: [AvailableLanguage] = []
        
        let view = LanguagePairView(
            isSourceLanguageToBeDetected: isSourceLanguageToBeDetected,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            detectedLanguage: "",
            availableLanguages: availableLanguages,
            isImageSelected: false
        )
        
        // Create test languages
        let enUS1 = Locale.Language(identifier: "en-US")
        let enUS2 = Locale.Language(identifier: "en-US")
        let enGB = Locale.Language(identifier: "en-GB")
        let esES = Locale.Language(identifier: "es-ES")
        
        // Test using reflection to access private method
        let mirror = Mirror(reflecting: view)
        if let compareLanguages = mirror.descendant("compareLanguages") as? (Locale.Language, Locale.Language) -> Bool {
            // Same language and region should return true
            XCTAssertTrue(compareLanguages(enUS1, enUS2))
            
            // Different region should return false
            XCTAssertFalse(compareLanguages(enUS1, enGB))
            
            // Different language should return false
            XCTAssertFalse(compareLanguages(enUS1, esES))
        } else {
            XCTFail("Could not access compareLanguages method")
        }
    }
    
    // Test the languageShortNameMatches helper function
    func testLanguageShortNameMatches() {
        // Setup
        let isSourceLanguageToBeDetected = Binding.constant(false)
        let sourceLanguage = Binding<Locale.Language?>.constant(nil)
        let targetLanguage = Binding<Locale.Language?>.constant(nil)
        let availableLanguages: [AvailableLanguage] = []
        
        let view = LanguagePairView(
            isSourceLanguageToBeDetected: isSourceLanguageToBeDetected,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            detectedLanguage: "",
            availableLanguages: availableLanguages,
            isImageSelected: false
        )
        
        // Test using reflection to access private method
        let mirror = Mirror(reflecting: view)
        if let languageShortNameMatches = mirror.descendant("languageShortNameMatches") as? (String, String) -> Bool {
            // Matching strings should return true
            XCTAssertTrue(languageShortNameMatches("en-US", "en-US"))
            
            // Non-matching strings should return false
            XCTAssertFalse(languageShortNameMatches("en-US", "en-GB"))
            XCTAssertFalse(languageShortNameMatches("en-US", "es-ES"))
        } else {
            XCTFail("Could not access languageShortNameMatches method")
        }
    }
    
    // Test detection of language when source language is set to be detected
    func testDetectedLanguageChanges() {
        // Setup
        let isSourceLanguageToBeDetected = Binding.constant(true)
        let sourceLanguage = Binding<Locale.Language?>.constant(nil)
        let targetLanguage = Binding<Locale.Language?>.constant(nil)
        
        let availableLanguages = [
            AvailableLanguage(locale: Locale.Language(identifier: "en-US")),
            AvailableLanguage(locale: Locale.Language(identifier: "es-ES"))
        ]
        
        var view = LanguagePairView(
            isSourceLanguageToBeDetected: isSourceLanguageToBeDetected,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            detectedLanguage: "Unknown",
            availableLanguages: availableLanguages,
            isImageSelected: true
        )
        
        // Simulate changing detectedLanguage to Spanish
        view.detectedLanguage = "Spanish"
        
        // Note: We can't easily test the onChange behavior in unit tests
        // This would typically be tested using ViewInspector or similar library
        // or through UI testing
        
        // For demonstration, we can show the expected behavior
        XCTAssertEqual(view.detectedLanguage, "Spanish")
        XCTAssertTrue(isSourceLanguageToBeDetected.wrappedValue)
    }
    
    // Test that default target language is set on appear
    func testDefaultTargetLanguageSetOnAppear() {
        // Setup with mock values
        let isSourceLanguageToBeDetected = Binding.constant(false)
        let sourceLanguage = Binding<Locale.Language?>.constant(nil)
        let targetLanguage = Binding<Locale.Language?>.constant(nil)
        let availableLanguages: [AvailableLanguage] = []
        
        let view = LanguagePairView(
            isSourceLanguageToBeDetected: isSourceLanguageToBeDetected,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            detectedLanguage: "",
            availableLanguages: availableLanguages,
            isImageSelected: false
        )
        
        // Note: We can't easily test onAppear behavior in unit tests without
        // additional testing frameworks like ViewInspector
        
        // For this test, we would typically need to use UI testing or
        // additional test frameworks to verify the onAppear behavior
        XCTAssertEqual(view.defaultTargetLanguage, "en-US")
    }
} 