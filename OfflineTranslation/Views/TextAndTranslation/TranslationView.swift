import SwiftUI
import Translation
import os

struct TranslationView: View {
    let sourceText: String
    let sourceLanguage: Locale.Language?
    let targetLanguage: Locale.Language?

    @State private var translatedText: String = ""
    @State private var translationError: Error?
    @State private var configuration: TranslationSession.Configuration?
    @State private var isTranslating: Bool = false

    init(
        sourceText: String,
        sourceLanguage: Locale.Language? = nil,
        targetLanguage: Locale.Language? = nil
    ) {
        self.sourceText = sourceText
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
    }
    
    var body: some View {
        VStack {
            if !translatedText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("**Translation:**")
                        .font(.headline)
                    
                    Text(translatedText)
                        .padding(.horizontal)
                }
            }
            else if isTranslating {
                HStack {
                    Text("Translating...")
                    ProgressView()
                }
            }
            else if translationError != nil {
                Text("Translation error: \(String(describing: translationError))")
                    .foregroundColor(.red)
            }
            else {
                Text("No translation yet.") // Dummy View to satisfy SwiftUI
                    .hidden() // This prevents UI clutter but keeps SwiftUI structure valid
            }
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