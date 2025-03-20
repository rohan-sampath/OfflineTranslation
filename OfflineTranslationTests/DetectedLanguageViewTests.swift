//
//  DetectedLanguageViewTests.swift
//  OfflineTranslationTests
//
//  Created by Rohan Sampath on 3/17/25.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import OfflineTranslation

extension DetectedLanguageView: Inspectable {}

class DetectedLanguageViewTests: XCTestCase {
    
    // MARK: - No Text Detected Tests
    
    func testNoTextDetected() throws {
        // Given
        let view = DetectedLanguageView(
            isTextDetected: false,
            detectedLanguage: "English",
            sourceLanguage: "Spanish",
            isSourceLanguageToBeDetected: false
        )
        
        // Then
        let text = try view.inspect().find(text: "No Text Detected. See List of Scripts & Languages that the Apple OCR Model currently supports.")
        XCTAssertEqual(try text.attributes().font(), Font.caption)
    }
    
    // MARK: - Source Language To Be Detected Tests
    
    func testSourceLanguageToBeDetected_EmptyDetectedLanguage() throws {
        // Given
        let view = DetectedLanguageView(
            isTextDetected: true,
            detectedLanguage: "",
            sourceLanguage: "",
            isSourceLanguageToBeDetected: true
        )
        
        // Then
        let text = try view.inspect().find(text: "Language not recognized.")
        XCTAssertEqual(try text.attributes().font(), Font.caption)
    }
    
    func testSourceLanguageToBeDetected_WithDetectedLanguage() throws {
        // Given - Text detected, language detected, and source language to be detected
        let view = DetectedLanguageView(
            isTextDetected: true,
            detectedLanguage: "French",
            sourceLanguage: "",
            isSourceLanguageToBeDetected: true
        )
        
        // Then - Should not display any text since there is a detected language
        // and isSourceLanguageToBeDetected is true
        XCTAssertThrowsError(try view.inspect().find(text: "Language not recognized."))
    }
    
    // MARK: - Source Language Not To Be Detected Tests
    
    func testSourceLanguageNotToBeDetected_EmptyDetectedLanguage() throws {
        // Given
        let view = DetectedLanguageView(
            isTextDetected: true,
            detectedLanguage: "",
            sourceLanguage: "German",
            isSourceLanguageToBeDetected: false
        )
        
        // Then - Should not display any text when detected language is empty
        let vStack = try view.inspect().vStack()
        XCTAssertEqual(try vStack.count(), 0)
    }
    
    func testSourceLanguageNotToBeDetected_EmptySourceLanguage() throws {
        // Given
        let view = DetectedLanguageView(
            isTextDetected: true,
            detectedLanguage: "Italian",
            sourceLanguage: "",
            isSourceLanguageToBeDetected: false
        )
        
        // Then
        let text = try view.inspect().find(text: "Detected Language: <Italian>")
        XCTAssertEqual(try text.attributes().font(), Font.caption)
    }
    
    func testSourceLanguageNotToBeDetected_MatchingLanguages() throws {
        // Given
        let view = DetectedLanguageView(
            isTextDetected: true,
            detectedLanguage: "Spanish",
            sourceLanguage: "Spanish",
            isSourceLanguageToBeDetected: false
        )
        
        // Then - Should not display any text when detected language matches source language
        let vStack = try view.inspect().vStack()
        XCTAssertEqual(try vStack.count(), 0)
    }
    
    func testSourceLanguageNotToBeDetected_DifferentLanguages() throws {
        // Given
        let view = DetectedLanguageView(
            isTextDetected: true,
            detectedLanguage: "Portuguese",
            sourceLanguage: "Spanish",
            isSourceLanguageToBeDetected: false
        )
        
        // Then
        let text = try view.inspect().find(text: "Detected Language: <Portuguese>. Translating from <Spanish> anyway.")
        XCTAssertEqual(try text.attributes().font(), Font.caption)
        XCTAssertEqual(try text.attributes().foregroundColor(), Color.gray)
    }
    
    // MARK: - Edge Cases
    
    func testEdgeCase_TextDetectedButBothLanguagesEmpty() throws {
        // Given
        let view = DetectedLanguageView(
            isTextDetected: true,
            detectedLanguage: "",
            sourceLanguage: "",
            isSourceLanguageToBeDetected: false
        )
        
        // Then - Should not display any text
        let vStack = try view.inspect().vStack()
        XCTAssertEqual(try vStack.count(), 0)
    }
    
    func testEdgeCase_NoTextDetectedAndSourceLanguageToBeDetected() throws {
        // Given
        let view = DetectedLanguageView(
            isTextDetected: false,
            detectedLanguage: "",
            sourceLanguage: "",
            isSourceLanguageToBeDetected: true
        )
        
        // Then - Should show "No Text Detected" message
        let text = try view.inspect().find(text: "No Text Detected. See List of Scripts & Languages that the Apple OCR Model currently supports.")
        XCTAssertEqual(try text.attributes().font(), Font.caption)
    }
} 