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

class TextRecognizer {
    @AppStorage("selectedOCRModel") private var selectedModel = OCRModel.appleVision
    
    func recognizeText(in image: UIImage, completion: @escaping (String, String) -> Void) {
        // Start with the user's preferred model
        print("🔍 Starting OCR with preferred model: \(selectedModel.rawValue)")
        processWithModel(image: image, model: selectedModel) { text, language in
            if !text.isEmpty {
                completion(text, language)
                return
            }
            
            print("⚠️ No text detected with preferred model. Trying alternative Latin model...")
            
            // Try the alternative Latin model
            let alternativeModel = (self.selectedModel == .appleVision) ? OCRModel.googleMLKitLatin : OCRModel.appleVision
            
            self.processWithModel(image: image, model: alternativeModel) { text, language in
                if !text.isEmpty {
                    completion(text, language)
                    return
                }
                
                print("⚠️ No text detected with alternative Latin model. Trying other language models...")
                
                // Try other language models in sequence
                self.tryRemainingModels(image: image, completion: completion)
            }
        }
    }
    
    private func processWithModel(image: UIImage, model: OCRModel, completion: @escaping (String, String) -> Void) {
        switch model {
        case .appleVision:
            recognizeTextWithVision(in: image, completion: completion)
        default:
            recognizeTextWithMLKit(in: image, model: model, completion: completion)
        }
    }
    
    private func tryRemainingModels(image: UIImage, completion: @escaping (String, String) -> Void) {
        // Try Chinese model
        print("🔍 Trying Chinese model...")
        processWithModel(image: image, model: .googleMLKitChinese) { text, language in
            if !text.isEmpty {
                completion(text, language)
                return
            }
            
            // Try Devanagari model
            print("🔍 Trying Devanagari model...")
            self.processWithModel(image: image, model: .googleMLKitDevanagari) { text, language in
                if !text.isEmpty {
                    completion(text, language)
                    return
                }
                
                // Try Japanese model
                print("🔍 Trying Japanese model...")
                self.processWithModel(image: image, model: .googleMLKitJapanese) { text, language in
                    if !text.isEmpty {
                        completion(text, language)
                        return
                    }
                    
                    // Try Korean model
                    print("🔍 Trying Korean model...")
                    self.processWithModel(image: image, model: .googleMLKitKorean) { text, language in
                        if !text.isEmpty {
                            completion(text, language)
                            return
                        }
                        
                        // If all models failed, return empty
                        print("❌ No text detected with any model")
                        completion("", "Unknown")
                    }
                }
            }
        }
    }
    
    // MARK: - Apple Vision OCR
    private func recognizeTextWithVision(in image: UIImage, completion: @escaping (String, String) -> Void) {
        print("🟢 Running Apple Vision OCR...")
        
        guard let cgImage = image.cgImage else {
            print("🚨 ERROR: No CGImage found in UIImage")
            completion("", "Unknown")
            return
        }
        
        let request: VNRecognizeTextRequest = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("🚨 ERROR: Apple Vision OCR failed - \(error.localizedDescription)")
                completion("", "Unknown")
                return
            }
            
            guard let observations: [VNRecognizedTextObservation] = request.results as? [VNRecognizedTextObservation] else {
                print("🚨 ERROR: No text observations found")
                completion("", "Unknown")
                return
            }
            
            let extractedText = observations.compactMap { observation -> String? in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            if extractedText.isEmpty {
                print("⚠️ Apple Vision OCR: No text detected")
                completion("", "Unknown")
                return
            }
            
            print("✅ Apple Vision OCR: Text detected")
            let detectedLanguage = self.detectLanguage(for: extractedText)
            completion(extractedText, detectedLanguage)
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("🚨 ERROR: Apple Vision OCR execution failed - \(error.localizedDescription)")
                completion("", "Unknown")
            }
        }
    }
    
    // MARK: - Google ML Kit OCR
    private func recognizeTextWithMLKit(in image: UIImage, model: OCRModel, completion: @escaping (String, String) -> Void) {
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
                completion("", "Unknown")
                return
            }
            
            guard let result = result else {
                print("⚠️ \(model.rawValue): No result returned")
                completion("", "Unknown")
                return
            }
            
            let extractedText = result.text
            
            if extractedText.isEmpty {
                print("⚠️ \(model.rawValue): No text detected")
                completion("", "Unknown")
                return
            }
            
            print("✅ \(model.rawValue): Text detected")
            let detectedLanguage = self.detectLanguage(for: extractedText)
            completion(extractedText, detectedLanguage)
        }
    }
    
    private func detectLanguage(for text: String) -> String {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        // Print all language hypotheses with probability > 0.05
        print("🌐 Language Hypotheses:")
        let hypotheses = recognizer.languageHypotheses(withMaximum: 10)
        
        // Sort hypotheses by probability in descending order
        let sortedHypotheses = hypotheses.sorted { $0.value > $1.value }
        
        // Track displayed probability
        var displayedProbability: Double = 0
        
        // Display languages with probability > 0.05
        for (language, probability) in sortedHypotheses where probability > 0.05 {
            print ("Raw Language: \(language)")
            let languageName = Locale.current.localizedString(forIdentifier: language.rawValue) ?? language.rawValue
            print("   - \(languageName): \(String(format: "%.2f", probability * 100))%")
            displayedProbability += probability
        }
        
        // Calculate "Other" as 1 - displayed probability (instead of totalProbability)
        let otherProbability = max(0, 1.0 - displayedProbability) // Ensure it's not negative
        if otherProbability > 0.001 { // Only show if it's meaningful (> 0.1%)
            print("   - (Other): \(String(format: "%.2f", otherProbability * 100))%")
        }
        
        if let dominantLanguage = recognizer.dominantLanguage {
            let languageName = Locale.current.localizedString(forIdentifier: dominantLanguage.rawValue) ?? "Unknown"
            print("🏆 Dominant Language: \(languageName)")
            return languageName
        }
        
        print("❓ No dominant language detected")
        return "Unknown"
    }
}
