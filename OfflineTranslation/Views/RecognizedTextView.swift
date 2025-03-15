import SwiftUI

struct RecognizedTextView: View {
    let detectedLanguage: String
    let recognizedText: String
    let translationUIStyle: TranslationUIStyle
    let translateAction: () -> Void
    
    @State private var isButtonDisabled: Bool = false
    @State private var showFullText: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 16) {
                
                // Detected Language
                Text(detectedLanguage == "No Text Detected" ? "No Text Detected" : "**Detected Language:** \(detectedLanguage)")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                // Recognized Text
                if !recognizedText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("**Original Text:**")
                            .font(.headline)
                        
                        Text(recognizedText)
                            .lineLimit(showFullText ? nil : 8)
                            .fixedSize(horizontal: false, vertical: true) // Allow multiline
                            .padding(.horizontal)
                        
                        if recognizedText.count > 100 { // Show the button only for longer text
                            Button(showFullText ? "Show Less" : "Show More") {
                                withAnimation {
                                    showFullText.toggle()
                                }
                            }
                            .padding(.horizontal)
                            .foregroundColor(.blue)
                            .transition(.opacity)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        TranslateButtonView(isDisabled: isButtonDisabled, action: translateAction)
                            .padding()
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 16)
                }
            )
        }
        .onChange(of: recognizedText) {
            showFullText = false // Reset "Show More" button when text changes
        }
    }
}