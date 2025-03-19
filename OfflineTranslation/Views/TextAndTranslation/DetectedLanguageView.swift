//
//  DetectedLanguageView.swift
//  OfflineTranslation
//
//  Created by Rohan Sampath on 3/17/25.
//

import SwiftUI

struct DetectedLanguageView: View {
    let detectedLanguage: String
    
    var body: some View {
        Text(detectedLanguage == "No Text Detected" ? "No Text Detected" : "**Detected Language:** \(detectedLanguage)")
            .font(.headline)
            .foregroundColor(.blue)
    }
}