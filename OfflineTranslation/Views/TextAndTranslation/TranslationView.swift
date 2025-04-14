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
        VStack(alignment: .leading, spacing: 12) {
            if !translatedText.isEmpty {
                Text(translatedText)
                    .font(.body)
                    .padding(.horizontal, 16) // 16 points of horizontal padding
                    .fixedSize(horizontal: false, vertical: true) // Ensures text wraps properly
                    .frame(maxWidth: .infinity, alignment: .leading) // Allow text to use full width
            }
            else if isTranslating {
                HStack {
                    ProgressView()
                        .padding(.trailing, 8)
                    Text("Translating...")
                }
                .padding(.horizontal, 16) // 16 points of horizontal padding
            }
            else if translationError != nil {
                Text("Translation error: \(String(describing: translationError))")
                    .foregroundColor(.red)
                    .padding(.horizontal, 16) // 16 points of horizontal padding
            }
            else {
                Text("Waiting for translation...")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16) // 16 points of horizontal padding
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Match RecognizedTextView
        .translationTask(configuration) { session in
            do {
                let response = try await session.translate(sourceText)
                isTranslating = false
                translatedText = response.targetText
            } catch {
                translationError = error
                isTranslating = false
                configuration?.invalidate()
                print("Translation error: \(error.localizedDescription)")
            }
        }
        .onAppear {
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
