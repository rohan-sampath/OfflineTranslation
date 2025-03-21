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
                        .lineLimit(showFullText ? nil : 8)
                        .fixedSize(horizontal: false, vertical: true) // Allow multiline
                        .padding(.horizontal)
                    
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