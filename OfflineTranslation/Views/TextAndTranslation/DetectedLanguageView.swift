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
    let possibleLanguages: [String]
    let sourceLanguage: String
    let isSourceLanguageToBeDetected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !isTextDetected {
                Text("No Text Detected. See List of Scripts & Languages that the Apple OCR Model currently supports.")
                    .font(.caption)
                    // This would be where we'd add a link to the list of supported scripts/languages
            } else if isSourceLanguageToBeDetected {
                if detectedLanguage == "Unknown" {
                    // Text detected but language not recognized
                    Text("Language not recognized.")
                        .font(.caption)
                } else {
                    // Show detected language and possible languages only if there are additional possible languages
                    if !possibleLanguages.isEmpty {
                        (Text("Source language is most likely ") + 
                         Text(detectedLanguage).bold() + 
                         Text(" but may also be ") + 
                         formatPossibleLanguagesText(possibleLanguages) +
                         Text("."))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    // No text displayed if possibleLanguages is empty
                }
            } else {
                // Source language is not to be detected
                if detectedLanguage == "Unknown" {
                    // Print nothing when detected language is empty
                } else {
                    if sourceLanguage.isEmpty {
                        // Source language is empty
                        if !possibleLanguages.isEmpty {
                            (Text("Source language is most likely ") + 
                             Text(detectedLanguage).bold() + 
                             Text(" but may also be ") + 
                             formatPossibleLanguagesText(possibleLanguages) +
                             Text("."))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        // No text displayed if possibleLanguages is empty
                    } else {
                        // Source language is not empty
                        if detectedLanguage == sourceLanguage {
                            // Print nothing when detected language equals source language
                        } else {
                            // Check if source language is one of the possible languages or the dominant language
                            let allPossibleLanguages = [detectedLanguage] + possibleLanguages
                            if !allPossibleLanguages.contains(sourceLanguage) {
                                // Only show this message if the source language is not one of the possible languages
                                let baseText = !possibleLanguages.isEmpty 
                                    ? (Text("Source language is most likely ") + 
                                       Text(detectedLanguage).bold() + 
                                       Text(" but may also be ") + 
                                       formatPossibleLanguagesText(possibleLanguages) +
                                       Text(". Translating from ") + 
                                       Text(sourceLanguage).bold() + 
                                       Text(" anyway..."))
                                    : (Text("Detected language is ") + 
                                       Text(detectedLanguage).bold() + 
                                       Text(". Translating from ") + 
                                       Text(sourceLanguage).bold() + 
                                       Text(" anyway..."))
                                
                                baseText
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // Helper function to format the list of possible languages as Text with bold formatting
    private func formatPossibleLanguagesText(_ languages: [String]) -> Text {
        switch languages.count {
        case 1:
            return Text(languages[0]).bold()
        case 2:
            return Text(languages[0]).bold() + Text(" or ") + Text(languages[1]).bold()
        default:
            var result = Text("")
            
            // Add all languages except the last one with commas
            for i in 0..<languages.count-1 {
                if i > 0 {
                    result = result + Text(", ")
                }
                result = result + Text(languages[i]).bold()
            }
            
            // Add the last language with "or"
            result = result + Text(", or ") + Text(languages.last!).bold()
            
            return result
        }
    }
}