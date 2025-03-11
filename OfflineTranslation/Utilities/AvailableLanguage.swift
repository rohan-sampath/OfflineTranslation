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
        let shortName = shortName()

        guard let localizedName = locale.localizedString(forLanguageCode: shortName) else {
            return "Unknown language code"
        }

        return "\(localizedName) (\(shortName))"
    }

    private func shortName() -> String {
        "\(locale.languageCode ?? "")-\(locale.region ?? "")"
    }

    static func <(lhs: AvailableLanguage, rhs: AvailableLanguage) -> Bool {
        return lhs.localizedName() < rhs.localizedName()
    }
}
