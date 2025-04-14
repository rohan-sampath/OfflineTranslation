//
//  TextRecognizer.swift
//  OfflineTranslation
//

import Vision
import NaturalLanguage
import UIKit
import SwiftUI
import MLKitTextRecognition
import MLKitTextRecognitionChinese
import MLKitTextRecognitionDevanagari
import MLKitTextRecognitionJapanese
import MLKitTextRecognitionKorean
import MLKitVision

// Define a struct to hold language detection results
struct LanguageDetectionResult {
    let dominantLanguage: String
    let possibleLanguages: [String]
}

class TextRecognizer {
    @AppStorage("selectedOCRModel") private var selectedModel = OCRModel.appleVision
    
    func recognizeText(in image: UIImage, completion: @escaping (String, LanguageDetectionResult) -> Void) {
        // Start with the user's preferred model
        print("🔍 Starting OCR with preferred model: \(selectedModel.rawValue)")
        processWithModel(image: image, model: selectedModel) { text, languageResult in
            if !text.isEmpty {
                completion(text, languageResult)
                return
            }
            
            print("⚠️ No text detected with preferred model. Trying alternative Latin model...")
            
            // Try the alternative Latin model
            let alternativeModel = (self.selectedModel == .appleVision) ? OCRModel.googleMLKitLatin : OCRModel.appleVision
            
            self.processWithModel(image: image, model: alternativeModel) { text, languageResult in
                if !text.isEmpty {
                    completion(text, languageResult)
                    return
                }
                
                print("⚠️ No text detected with alternative Latin model. Trying other language models...")
                
                // Try other language models in sequence
                self.tryRemainingModels(image: image, completion: completion)
            }
        }
    }
    
    private func processWithModel(image: UIImage, model: OCRModel, completion: @escaping (String, LanguageDetectionResult) -> Void) {
        switch model {
        case .appleVision:
            recognizeTextWithVision(in: image, completion: completion)
        default:
            recognizeTextWithMLKit(in: image, model: model, completion: completion)
        }
    }
    
    private func tryRemainingModels(image: UIImage, completion: @escaping (String, LanguageDetectionResult) -> Void) {
        // Try Chinese model
        print("🔍 Trying Chinese model...")
        processWithModel(image: image, model: .googleMLKitChinese) { text, languageResult in
            if !text.isEmpty {
                completion(text, languageResult)
                return
            }
            
            // Try Devanagari model
            print("🔍 Trying Devanagari model...")
            self.processWithModel(image: image, model: .googleMLKitDevanagari) { text, languageResult in
                if !text.isEmpty {
                    completion(text, languageResult)
                    return
                }
                
                // Try Japanese model
                print("🔍 Trying Japanese model...")
                self.processWithModel(image: image, model: .googleMLKitJapanese) { text, languageResult in
                    if !text.isEmpty {
                        completion(text, languageResult)
                        return
                    }
                    
                    // Try Korean model
                    print("🔍 Trying Korean model...")
                    self.processWithModel(image: image, model: .googleMLKitKorean) { text, languageResult in
                        if !text.isEmpty {
                            completion(text, languageResult)
                            return
                        }
                        
                        // If all models failed, return empty
                        print("❌ No text detected with any model")
                        let emptyResult = LanguageDetectionResult(dominantLanguage: "Unknown", possibleLanguages: [])
                        completion("", emptyResult)
                    }
                }
            }
        }
    }
    
    // MARK: - Apple Vision OCR
    private func recognizeTextWithVision(in image: UIImage, completion: @escaping (String, LanguageDetectionResult) -> Void) {
        print("🟢 Running Apple Vision OCR...")
        
        guard let cgImage = image.cgImage else {
            print("🚨 ERROR: No CGImage found in UIImage")
            let emptyResult = LanguageDetectionResult(dominantLanguage: "Unknown", possibleLanguages: [])
            completion("", emptyResult)
            return
        }
        
        let request: VNRecognizeTextRequest = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("🚨 ERROR: Apple Vision OCR failed - \(error.localizedDescription)")
                let emptyResult = LanguageDetectionResult(dominantLanguage: "Unknown", possibleLanguages: [])
                completion("", emptyResult)
                return
            }
            
            guard let observations: [VNRecognizedTextObservation] = request.results as? [VNRecognizedTextObservation] else {
                print("🚨 ERROR: No text observations found")
                let emptyResult = LanguageDetectionResult(dominantLanguage: "Unknown", possibleLanguages: [])
                completion("", emptyResult)
                return
            }
            
            let extractedText = observations.compactMap { observation -> String? in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            if extractedText.isEmpty {
                print("⚠️ Apple Vision OCR: No text detected")
                let emptyResult = LanguageDetectionResult(dominantLanguage: "Unknown", possibleLanguages: [])
                completion("", emptyResult)
                return
            }
            
            print("✅ Apple Vision OCR: Text detected")
            let languageResult = self.detectLanguage(for: extractedText)
            completion(extractedText, languageResult)
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("🚨 ERROR: Apple Vision OCR execution failed - \(error.localizedDescription)")
                let emptyResult = LanguageDetectionResult(dominantLanguage: "Unknown", possibleLanguages: [])
                completion("", emptyResult)
            }
        }
    }
    
    // MARK: - Google ML Kit OCR
    private func recognizeTextWithMLKit(in image: UIImage, model: OCRModel, completion: @escaping (String, LanguageDetectionResult) -> Void) {
        print("🟢 Running \(model.rawValue)...")
        
        // Create text recognizer based on selected model
        let textRecognizer: MLKitTextRecognition.TextRecognizer
        
        switch model {
        case .googleMLKitLatin:
            let options = TextRecognizerOptions()
            textRecognizer = MLKitTextRecognition.TextRecognizer.textRecognizer(options: options)
        case .googleMLKitChinese:
            let options = ChineseTextRecognizerOptions()
            textRecognizer = MLKitTextRecognition.TextRecognizer.textRecognizer(options: options)
        case .googleMLKitDevanagari:
            let options = DevanagariTextRecognizerOptions()
            textRecognizer = MLKitTextRecognition.TextRecognizer.textRecognizer(options: options)
        case .googleMLKitJapanese:
            let options = JapaneseTextRecognizerOptions()
            textRecognizer = MLKitTextRecognition.TextRecognizer.textRecognizer(options: options)
        case .googleMLKitKorean:
            let options = KoreanTextRecognizerOptions()
            textRecognizer = MLKitTextRecognition.TextRecognizer.textRecognizer(options: options)
        default:
            // Default to Latin if somehow we get here with Apple Vision
            let options = TextRecognizerOptions()
            textRecognizer = MLKitTextRecognition.TextRecognizer.textRecognizer(options: options)
        }
        
        // Convert UIImage to MLKit VisionImage
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation
        
        // Process the image
        textRecognizer.process(visionImage) { result, error in
            if let error = error {
                print("🚨 ERROR: \(model.rawValue) failed - \(error.localizedDescription)")
                let emptyResult = LanguageDetectionResult(dominantLanguage: "Unknown", possibleLanguages: [])
                completion("", emptyResult)
                return
            }
            
            guard let result = result else {
                print("⚠️ \(model.rawValue): No result returned")
                let emptyResult = LanguageDetectionResult(dominantLanguage: "Unknown", possibleLanguages: [])
                completion("", emptyResult)
                return
            }
            
            let extractedText = result.text
            
            if extractedText.isEmpty {
                print("⚠️ \(model.rawValue): No text detected")
                let emptyResult = LanguageDetectionResult(dominantLanguage: "Unknown", possibleLanguages: [])
                completion("", emptyResult)
                return
            }
            
            print("✅ \(model.rawValue): Text detected")
            let languageResult = self.detectLanguage(for: extractedText)
            completion(extractedText, languageResult)
        }
    }
    
    private func detectLanguage(for text: String) -> LanguageDetectionResult {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        // Get language hypotheses with probability > 0.05
        print("🌐 Language Hypotheses:")
        let hypotheses = recognizer.languageHypotheses(withMaximum: 10)
        
        // Sort hypotheses by probability in descending order
        let sortedHypotheses = hypotheses.sorted { $0.value > $1.value }
        
        // Track displayed probability
        var displayedProbability: Double = 0
        
        // Store languages with their probabilities to maintain order
        var languagesWithProbabilities: [(name: String, probability: Double)] = []
        var hasEnglish = false
        
        for (language, probability) in sortedHypotheses {
            let languageName = Locale.current.localizedString(forIdentifier: language.rawValue) ?? language.rawValue
            print("   - \(languageName): \(String(format: "%.2f", probability * 100))%")
            
            // Check if this language meets our criteria for possible languages
            if probability >= 0.1 || (language.rawValue == "en" && probability >= 0.05) {
                languagesWithProbabilities.append((languageName, probability))
                
                // Track if English is in the list
                if language.rawValue == "en" {
                    hasEnglish = true
                }
            }
            
            displayedProbability += probability
        }
        
        // Calculate "Other" as 1 - displayed probability
        let otherProbability = max(0, 1.0 - displayedProbability) // Ensure it's not negative
        if otherProbability > 0.001 { // Only show if it's meaningful (> 0.1%)
            print("   - (Other): \(String(format: "%.2f", otherProbability * 100))%")
        }
        
        // Get dominant language
        var dominantLanguage = "Unknown"
        if let dominant = recognizer.dominantLanguage {
            dominantLanguage = Locale.current.localizedString(forIdentifier: dominant.rawValue) ?? "Unknown"
            print("🏆 Dominant Language: \(dominantLanguage)")
        } else {
            print("❓ No dominant language detected")
        }
        
        // Remove the dominant language from possible languages
        languagesWithProbabilities = languagesWithProbabilities.filter { $0.name != dominantLanguage }
        
        // Sort by probability (should already be sorted, but just to be sure)
        languagesWithProbabilities.sort { $0.probability > $1.probability }
        
        // Extract just the language names, maintaining probability order
        var possibleLanguages = languagesWithProbabilities.map { $0.name }
        
        // Prioritize English if it's in the list (move it to the front)
        if hasEnglish, let englishIndex = possibleLanguages.firstIndex(of: "English"), englishIndex > 0 {
            possibleLanguages.remove(at: englishIndex)
            possibleLanguages.insert("English", at: 0)
        }
        
        // Limit to at most 4 possible languages
        if possibleLanguages.count > 4 {
            possibleLanguages = Array(possibleLanguages.prefix(4))
        }
        
        print("📊 Possible Languages: \(possibleLanguages.joined(separator: ", "))")
        
        return LanguageDetectionResult(dominantLanguage: dominantLanguage, possibleLanguages: possibleLanguages)
    }
}
