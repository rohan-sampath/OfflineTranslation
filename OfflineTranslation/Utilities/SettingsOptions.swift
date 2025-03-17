import Foundation

public enum OCRModel: String, CaseIterable {
    case appleVision = "Apple Vision OCR (default)"
    case googleMLKitLatin = "Google ML Kit (Latin)"
    case googleMLKitChinese = "Google ML Kit (Chinese)"
    case googleMLKitDevanagari = "Google ML Kit (Devanagari)"
    case googleMLKitJapanese = "Google ML Kit (Japanese)"
    case googleMLKitKorean = "Google ML Kit (Korean)"
}

public enum TranslationUIStyle: String, CaseIterable {
    case modalSheet = "Modal Sheet"
    case inlineDisplay = "Directly in App"
}