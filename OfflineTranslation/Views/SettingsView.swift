import SwiftUI
import Foundation

struct SettingsView: View {
    @AppStorage("selectedOCRModel") private var selectedModel = OCRModel.appleVision
    @AppStorage("translationUIStyle") private var translationUIStyle = TranslationUIStyle.modalSheet
    
    var body: some View {
        NavigationView {
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
                    header: Text("About Offline Translation"), 
                    footer: Text("This app uses on-device machine learning models to recognize and translate text in images.\n\n Different models work better for different languages and scripts. If no text is detected, the app will automatically try other models.")
                ) {
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}