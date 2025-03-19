import SwiftUI

struct RecognizedTextView: View {
    let recognizedText: String
    
    @State private var showFullText: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Recognized Text
            if !recognizedText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("**Original Text:**    ")
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
        .onChange(of: recognizedText) {
            showFullText = false // Reset "Show More" button when text changes
        }
    }
}