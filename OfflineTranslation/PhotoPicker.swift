//
//  PhotoPicker.swift
//  OfflineTranslation
//

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var recognizedText: String
    @Binding var detectedLanguage: String
    var onTextRecognized: ((String, String) -> Void)? = nil

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        if let uiImage = image as? UIImage {
                            self.parent.selectedImage = uiImage
                            
                            print("📸 PhotoPicker: Image selected, about to call TextRecognizer")
                            
                            // Perform text recognition and language detection
                            TextRecognizer().recognizeText(in: uiImage) { recognizedText, detectedLanguage in
                                print("📝 TextRecognizer: Text recognition completed")
                                print("📝 Recognized text: \(recognizedText.prefix(50))")
                                print("🌐 Detected language: \(detectedLanguage)")
                                
                                self.parent.recognizedText = recognizedText
                                self.parent.detectedLanguage = detectedLanguage
                                
                                // Call the callback if provided
                                self.parent.onTextRecognized?(recognizedText, detectedLanguage)
                            }
                        } else {
                            print("❌ PhotoPicker: Failed to get UIImage from selected photo")
                        }
                    }
                }
            }
        }
    }
}
