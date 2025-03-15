//
//  AvailableLanguage.swift
//  OfflineTranslation
//
//  Created by Rohan Sampath on 3/11/25.
// Abstract:
// The structure that describes the properties of a language to use in a translation.

import Foundation

struct AvailableLanguage: Identifiable, Hashable, Comparable {
    var id: Self { self }
    let locale: Locale.Language

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
