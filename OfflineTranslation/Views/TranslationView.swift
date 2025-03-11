import SwiftUI

struct TranslationView: View {
    let translationManager: TranslationManager
    let translationUIStyle: TranslationUIStyle
    
    var body: some View {
        if translationUIStyle == .inlineDisplay && !translationManager.translatedText.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("**Translation:**")
                    .font(.headline)
                
                Text(translationManager.translatedText)
                    .padding(.horizontal)
            }
        }
        
        if translationUIStyle == .inlineDisplay && translationManager.isTranslating {
            HStack {
                Text("Translating...")
                ProgressView()
            }
        } else if translationUIStyle == .inlineDisplay && translationManager.translationError != nil {
            Text("Translation error: \(translationManager.translationError!)")
                .foregroundColor(.red)
        }
    }
}