//
//  DetectedLanguageView.swift
//  OfflineTranslation
//
//  Created by Rohan Sampath on 3/17/25.
//

import SwiftUI

struct DetectedLanguageView: View {
    let isTextDetected: Bool
    let detectedLanguage: String
    let sourceLanguage: String
    let isSourceLanguageToBeDetected: Bool
    
    var body: some View {
        if !isTextDetected {
            Text("No Text Detected. See List of Scripts & Languages that the Apple OCR Model currently supports.")
                .font(.caption)
                // This would be where we'd add a link to the list of supported scripts/languages
        } else if isSourceLanguageToBeDetected {
            if detectedLanguage == "Unknown" {
                // Text detected but language not recognized
                Text("Language not recognized.")
                    .font(.caption)
            }
        } else {
            // Source language is not to be detected
            if detectedLanguage == "Unknown" {
                // Print nothing when detected language is empty
            } else {
                if sourceLanguage.isEmpty {
                    // Source language is empty
                    Text("Detected Language: <\(detectedLanguage)>")
                        .font(.caption)
                } else {
                    // Source language is not empty
                    if detectedLanguage == sourceLanguage {
                        // Print nothing when detected language equals source language
                    } else {
                        // Detected language is not equal to source language
                        Text("Detected Language: <\(detectedLanguage)>. Translating from <\(sourceLanguage)> anyway.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}