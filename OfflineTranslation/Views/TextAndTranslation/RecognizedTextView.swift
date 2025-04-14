import SwiftUI

struct RecognizedTextHeaderView: View {
    var body: some View {
        Text("**Original Text**")
            .font(.headline)
    }
}

struct RecognizedTextView: View {
    let recognizedText: String
    
    @State private var showFullText: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Recognized Text
            if !recognizedText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(recognizedText)
                        .lineLimit(nil) // No line limit - show all text
                        .fixedSize(horizontal: false, vertical: true) // Allow multiline
                        .padding(.horizontal, 16) // Minimal horizontal padding
                    
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onChange(of: recognizedText) {
            showFullText = false // Reset "Show More" button when text changes
        }
    }
}