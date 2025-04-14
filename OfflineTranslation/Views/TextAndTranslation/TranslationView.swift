import SwiftUI
import Translation

struct TranslationHeaderView: View {
    var body: some View {
        Text("**Translation**")
            .font(.headline)
    }
}

struct TranslationView: View {
    let sourceText: String
    let sourceLanguage: Locale.Language
    let targetLanguage: Locale.Language

    @State private var translatedText: String = ""
    @State private var translationError: Error?
    @State private var configuration: TranslationSession.Configuration?
    @State private var isTranslating: Bool = false

    init?(
        sourceText: String,
        sourceLanguage: Locale.Language?,
        targetLanguage: Locale.Language?
    ) {
        var errorMessage: String = ""
        if sourceText.isEmpty {
            errorMessage += "Error: sourceText cannot be empty.\n"
        }
        if sourceLanguage == nil {
            errorMessage += "Error: sourceLanguage must be provided and valid.\n"
        }
        if targetLanguage == nil {
            errorMessage += "Error: targetLanguage must be provided and valid.\n"
        }
        if !errorMessage.isEmpty {
            print("TranslationView Initialization Failed:\n" + errorMessage)
            return nil
        }
        self.sourceText = sourceText
        self.sourceLanguage = sourceLanguage!
        self.targetLanguage = targetLanguage!
    }    
    
    var body: some View {
        ScrollView { // Makes the entire view scrollable
            VStack(alignment: .leading, spacing: 12) { // Leading alignment for all elements
                if !translatedText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(translatedText)
                            .padding(.horizontal)
                            .foregroundColor(.primary) // Ensure text uses primary color
                            .font(.body.bold()) // Make text bold for visibility
                            .fixedSize(horizontal: false, vertical: true) // Ensures text wraps properly
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.yellow.opacity(0.1)) // Add subtle background for debugging
                    }
                    .onAppear {
                        print("[TranslationView] Now displaying translated text: \(translatedText)")
                    }
                }
                else if isTranslating {
                    VStack(alignment: .leading, spacing: 8) { // Change to VStack for text wrapping
                        Text("Translating...")
                            .fixedSize(horizontal: false, vertical: true) // Ensures wrapping
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                else if translationError != nil {
                    VStack(alignment: .leading, spacing: 8) { // Change to VStack for text wrapping
                        Text("Translation error: \(String(describing: translationError))")
                            .foregroundColor(.red)
                            .fixedSize(horizontal: false, vertical: true) // Ensures wrapping
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                else {
                    Text("No translation yet.") // Dummy View to satisfy SwiftUI
                        .hidden() // Prevents UI clutter but keeps SwiftUI structure valid
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding() // Adds padding to prevent text from touching the screen edges
        }        
        .translationTask(configuration) { session in
                do {
                    let response = try await session.translate(sourceText)
                    isTranslating = false
                    translatedText = response.targetText
                    print("Translation View: TRANSLATED TEXT: \(translatedText)")
                } catch {
                    translationError = error
                    isTranslating = false
                    configuration?.invalidate()
                    print("Translation error: \(error.localizedDescription)")
                }
            }
            .onAppear {
                print("Translation View: Starting translation...")
                print("Source Text: \(sourceText), Source Language: \(String(describing: sourceLanguage)), Target Language: \(String(describing: targetLanguage))")
                if translatedText.isEmpty && !isTranslating && translationError == nil {
                    print("Translation View: NOT TRANSLATING")
                }
                startTranslation()
            }
    }
    
    private func startTranslation() {
        configuration?.invalidate()
        translationError = nil
        isTranslating = true
        configuration = .init(
            source: sourceLanguage,
            target: targetLanguage
        )
    }
}