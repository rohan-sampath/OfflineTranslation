import SwiftUI
import Foundation
import Translation

struct SettingsView: View {
    @AppStorage("selectedOCRModel") private var selectedModel = OCRModel.appleVision
    @AppStorage("translationUIStyle") private var translationUIStyle = TranslationUIStyle.modalSheet
    @AppStorage("defaultTargetLanguage") private var defaultTargetLanguage: String = "en-US"
    
    @State private var availableLanguages: [AvailableLanguage] = []
    @State private var isLoadingLanguages = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Text Recognition Model")) {
                    Picker("OCR Model", selection: $selectedModel) {
                        ForEach(OCRModel.allCases, id: \.self) { model in
                            Text(model.rawValue).tag(model)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section(
                    header: Text("Translation UI"), 
                    footer: Text("Modal Sheet: this option brings up a sheet from the bottom of your screen " +
                                 "that contains the translation.\n" +
                                 "Directly in App: this option directly provides the translation underneath " +
                                 "the original text.")) 
                {
                    Picker("Translation UI", selection: $translationUIStyle) {
                        ForEach(TranslationUIStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section(
                    header: Text("Default Target Language"),
                    footer: Text("This is the default language that text will be translated to. Apple's Translation API determines the list of supported languages. A language must be downloaded before it can be used in a translation.")
                ) {
                    if isLoadingLanguages {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    } else {
                        Picker("Target Language", selection: $defaultTargetLanguage) {
                            ForEach(availableLanguages, id: \.id) { language in
                                Text(language.localizedName()).tag(language.shortName())
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                }
                
                Section(
                    header: Text("About Offline Translation"), 
                    footer: Text("This app uses on-device machine learning models to recognize and translate text in images.\n\n Different models work better for different languages and scripts. If no text is detected, the app will automatically try other models.")
                ) {
                }
            }
            .navigationTitle("Settings")
            .withSupportedLanguages(
                availableLanguages: $availableLanguages,
                isLoading: $isLoadingLanguages
            )
        }                              
    }
}

#Preview {
    SettingsView()
}

