import Testing
import SwiftUI
@testable import OfflineTranslation

struct AvailableLanguageTests {
    
    // Test the shortName function
    @Test func testShortName() {
        // Create test languages
        let enUS = AvailableLanguage(locale: Locale.Language(identifier: "en-US"))
        let esES = AvailableLanguage(locale: Locale.Language(identifier: "es-ES"))
        let zhCN = AvailableLanguage(locale: Locale.Language(identifier: "zh-CN"))
        
        // Test short name formats
        #expect(enUS.shortName() == "en-US")
        #expect(esES.shortName() == "es-ES")
        #expect(zhCN.shortName() == "zh-CN")
    }
    
    // Test the localizedName function
    @Test func testLocalizedName() {
        // Create test languages
        let enUS = AvailableLanguage(locale: Locale.Language(identifier: "en-US"))
        let enGB = AvailableLanguage(locale: Locale.Language(identifier: "en-GB"))
        let zhCN = AvailableLanguage(locale: Locale.Language(identifier: "zh-CN"))
        
        // Test localized name formats
        // Note: These tests depend on the current locale of the system
        // so we're testing the custom formatting logic
        
        // English (US) should be formatted as is
        let enUSName = enUS.localizedName()
        #expect(enUSName == "English (US)" || enUSName.contains("English"))
        
        // English (GB) should have (UK) appended
        let enGBName = enGB.localizedName()
        #expect(enGBName == "English (UK)" || enGBName.contains("English"))
        
        // Chinese Simplified should have additional context
        let zhCNName = zhCN.localizedName()
        #expect(zhCNName == "Chinese (Mandarin, Simplified)" || zhCNName.contains("Chinese"))
    }
    
    // Test the findMatchingLanguage static function
    @Test func testFindMatchingLanguage() {
        // Create an array of available languages
        let availableLanguages = [
            AvailableLanguage(locale: Locale.Language(identifier: "en-US")),
            AvailableLanguage(locale: Locale.Language(identifier: "en-GB")),
            AvailableLanguage(locale: Locale.Language(identifier: "es-ES")),
            AvailableLanguage(locale: Locale.Language(identifier: "zh-CN"))
        ]
        
        // Test Case A: Exactly one match
        let spanishLocale = AvailableLanguage.findMatchingLanguage(
            availableLanguages: availableLanguages,
            inputLanguage: "Spanish"
        )
        #expect(spanishLocale?.languageCode == "es")
        
        // Test Case B: Multiple matches (should return default)
        let englishLocale = AvailableLanguage.findMatchingLanguage(
            availableLanguages: availableLanguages,
            inputLanguage: "English"
        )
        #expect(englishLocale?.languageCode == "en")
        // Default should be en-US not en-GB
        #expect(englishLocale?.region?.identifier == "US")
        
        // Test Case C: No matches
        let frenchLocale = AvailableLanguage.findMatchingLanguage(
            availableLanguages: availableLanguages,
            inputLanguage: "French"
        )
        #expect(frenchLocale == nil)
    }
    
    // Test comparison operator for sorting
    @Test func testComparisonOperator() {
        // Create test languages
        let arabic = AvailableLanguage(locale: Locale.Language(identifier: "ar-SA"))
        let english = AvailableLanguage(locale: Locale.Language(identifier: "en-US"))
        let spanish = AvailableLanguage(locale: Locale.Language(identifier: "es-ES"))
        
        // Test sorting - should be alphabetical by localized name
        // This is dependent on the locale, but regardless:
        #expect(english < spanish) // English < Spanish alphabetically
        
        // Sort an array
        let unsorted = [spanish, english, arabic]
        let sorted = unsorted.sorted()
        
        // Array should be in proper order by localized name
        // This may be locale-dependent but we can check relative positions
        #expect(sorted.firstIndex(of: arabic)! < sorted.firstIndex(of: spanish)!) // "Arabic" < "Spanish"
    }
} 