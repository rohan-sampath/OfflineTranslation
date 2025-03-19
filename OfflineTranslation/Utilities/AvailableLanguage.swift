//
//  AvailableLanguage.swift
//  OfflineTranslation
//
//  Created by Rohan Sampath on 3/11/25.
// Abstract:
// The structure that describes the properties of a language to use in a translation.

import Foundation
import SwiftUI

struct AvailableLanguage: Identifiable, Hashable, Comparable {
    var id: Self { self }
    let locale: Locale.Language

    func languageNameOnly() -> String {
        let locale = Locale.current
        guard let languageName = locale.localizedString(forLanguageCode: shortName()) else {
            return "Unknown"
        }
        return languageName
    }

    func localizedName() -> String {
        let locale = Locale.current
        let shortCode: String = shortName()

        guard let localizedName: String = locale.localizedString(forLanguageCode: shortCode) else {
            return "Unknown language code"
        }
        
        return formatLanguageDisplay(localizedName: localizedName, shortCode: shortCode)
    }

    func shortName() -> String {
        "\(locale.languageCode ?? "")-\(locale.region ?? "")"
    }
    
    private func formatLanguageDisplay(localizedName: String, shortCode: String) -> String {
        switch (localizedName, shortCode) {
        case ("English", "en-GB"):
            return "English (UK)"
        case ("English", "en-US"):
            return "English (US)"
        case ("Chinese", "zh-CN"):
            return "Chinese (Mandarin, Simplified)"
        case ("Chinese", "zh-TW"):
            return "Chinese (Mandarin, Traditional)"
        case ("Spanish", "es-ES"):
            return "Spanish (Spain)"
        case ("Portuguese", "pt-BR"):
            return "Portuguese (Brazil)"
        default:
            return localizedName
        }
    }

    static func <(lhs: AvailableLanguage, rhs: AvailableLanguage) -> Bool {
        return lhs.localizedName() < rhs.localizedName()
    }
}
// Extension to add the language matching function
extension AvailableLanguage {
    // Default language codes for common languages with multiple variants
    private enum DefaultLanguage: String {
        case english = "en-US"
        case spanish = "es-ES"
        case chinese = "zh-CN"
        case portuguese = "pt-BR"
        
        static func getDefault(for localizedName: String) -> String? {
            switch localizedName {
            case "English": return DefaultLanguage.english.rawValue
            case "Spanish": return DefaultLanguage.spanish.rawValue
            case "Chinese": return DefaultLanguage.chinese.rawValue
            case "Portuguese": return DefaultLanguage.portuguese.rawValue
            default: return nil
            }
        }
    }
    
    static func findMatchingLanguage(availableLanguages: [AvailableLanguage], inputLanguage: String) -> Locale.Language? {
        // Find all languages that match the input string
        let matchingLanguages: [AvailableLanguage] = availableLanguages.filter { $0.languageNameOnly() == inputLanguage }
        print("Localized Names for each available Language: \(availableLanguages.map { $0.localizedName() })")
        print ("findMatchingLanguage: \(inputLanguage) -> \(matchingLanguages)")
        
        // Case A: Exactly one match
        if matchingLanguages.count == 1 {
            return matchingLanguages[0].locale
        }
        // Case B: Multiple matches - use defaults
        else if matchingLanguages.count > 1 {
            if let defaultCode = DefaultLanguage.getDefault(for: inputLanguage) {
                return LanguageUtilities.getLocaleLanguage(from: defaultCode)
            } else {
                // If we have multiple matches but no default, return the first one
                return matchingLanguages[0].locale
            }
        }
        // Case C: No matches
        else {
            return nil
        }
    }
}
