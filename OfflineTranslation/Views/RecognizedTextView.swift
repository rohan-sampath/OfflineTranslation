import SwiftUI

struct RecognizedTextView: View {
    let detectedLanguage: String
    let recognizedText: String
    let translationUIStyle: TranslationUIStyle
    let translateAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("**Language:** \(detectedLanguage)")
                .font(.headline)
                .foregroundColor(.blue)
            
            if !recognizedText.isEmpty && translationUIStyle == .modalSheet {
                Button(action: translateAction) {
                    Text("Translate")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.vertical, 8)
            }
            
            if !recognizedText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("**Original Text:**")
                        .font(.headline)
                    
                    Text(recognizedText)
                        .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}