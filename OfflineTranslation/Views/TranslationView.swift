import SwiftUI
import Translation

struct TranslationView: View {
    let sourceText: String
    let sourceLanguage: Locale.Language?
    let targetLanguage: Locale.Language?
    
    @State private var translatedText = ""
    @State private var translationError: Error?
    @State private var configuration: TranslationSession.Configuration?
    
    init(
        sourceText: String,
        source: Locale.Language? = nil,
        target: Locale.Language? = nil
    ) {
        self.sourceText = sourceText
        self.sourceLanguage = source
        self.targetLanguage = target
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
            
            if configuration != nil {
                HStack {
                    Text("Translating...")
                    ProgressView()
                }
            } else if translationError != nil {
                Text("Translation error: \(String(describing: translationError))")
                    .foregroundColor(.red)
            }
        }
        .translationTask(configuration) { session in
            do {
                let response = try await session.translate(sourceText)
                translatedText = response.targetText
                print ("Translation View: TRANSLATED TEXT: \(translatedText)")
                configuration?.invalidate()
            } catch {
                translationError = error
                configuration?.invalidate()
            }
        }
        .onAppear {
            // Start translation immediately when view appears
            startTranslation()
        }
    }
    
    private func startTranslation() {
        // Initialize configuration with language parameters
        configuration = .init(
            source: sourceLanguage,
            target: targetLanguage
        )
    }
}