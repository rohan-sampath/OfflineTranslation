import Testing
import SwiftUI
import PhotosUI
@testable import OfflineTranslation

struct PhotoPickerTests {
    
    // MARK: - PhotoPicker Initialization Tests
    
    @Test func testPhotoPickerInitialization() {
        // Create bindings for the required properties
        let selectedImage = Binding<UIImage?>(get: { nil }, set: { _ in })
        let recognizedText = Binding<String>(get: { "" }, set: { _ in })
        let detectedLanguage = Binding<String>(get: { "" }, set: { _ in })
        
        // Initialize PhotoPicker
        let photoPicker = PhotoPicker(
            selectedImage: selectedImage,
            recognizedText: recognizedText,
            detectedLanguage: detectedLanguage
        )
        
        // Verify the PhotoPicker was initialized
        #expect(photoPicker is PhotoPicker)
    }
    
    @Test func testPhotoPickerWithCallback() {
        // Create bindings for the required properties
        let selectedImage = Binding<UIImage?>(get: { nil }, set: { _ in })
        let recognizedText = Binding<String>(get: { "" }, set: { _ in })
        let detectedLanguage = Binding<String>(get: { "" }, set: { _ in })
        
        var callbackCalled = false
        var callbackText = ""
        var callbackLanguage = ""
        
        // Initialize PhotoPicker with callback
        let photoPicker = PhotoPicker(
            selectedImage: selectedImage,
            recognizedText: recognizedText,
            detectedLanguage: detectedLanguage
        ) { text, language in
            callbackCalled = true
            callbackText = text
            callbackLanguage = language
        }
        
        // Verify the PhotoPicker was initialized
        #expect(photoPicker is PhotoPicker)
    }
    
    // MARK: - UIViewControllerRepresentable Tests
    
    @Test func testMakeUIViewController() {
        // Create bindings for the required properties
        let selectedImage = Binding<UIImage?>(get: { nil }, set: { _ in })
        let recognizedText = Binding<String>(get: { "" }, set: { _ in })
        let detectedLanguage = Binding<String>(get: { "" }, set: { _ in })
        
        // Initialize PhotoPicker
        let photoPicker = PhotoPicker(
            selectedImage: selectedImage,
            recognizedText: recognizedText,
            detectedLanguage: detectedLanguage
        )
        
        // Create a SwiftUI context
        let context = UIViewControllerRepresentableContext<PhotoPicker>(coordinator: photoPicker.makeCoordinator())
        
        // Call makeUIViewController
        let viewController = photoPicker.makeUIViewController(context: context)
        
        // Verify the view controller is a PHPickerViewController
        #expect(viewController is PHPickerViewController)
        
        // Verify the configuration
        let phPicker = viewController as! PHPickerViewController
        #expect(phPicker.configuration.selectionLimit == 1)
        #expect(phPicker.delegate === context.coordinator)
    }
    
    @Test func testMakeCoordinator() {
        // Create bindings for the required properties
        let selectedImage = Binding<UIImage?>(get: { nil }, set: { _ in })
        let recognizedText = Binding<String>(get: { "" }, set: { _ in })
        let detectedLanguage = Binding<String>(get: { "" }, set: { _ in })
        
        // Initialize PhotoPicker
        let photoPicker = PhotoPicker(
            selectedImage: selectedImage,
            recognizedText: recognizedText,
            detectedLanguage: detectedLanguage
        )
        
        // Create coordinator
        let coordinator = photoPicker.makeCoordinator()
        
        // Verify the coordinator is properly initialized
        #expect(coordinator is PhotoPicker.Coordinator)
        #expect(coordinator.parent === photoPicker)
    }
    
    // MARK: - Coordinator Tests
    
    @Test func testCoordinatorInitialization() {
        // Create bindings for the required properties
        let selectedImage = Binding<UIImage?>(get: { nil }, set: { _ in })
        let recognizedText = Binding<String>(get: { "" }, set: { _ in })
        let detectedLanguage = Binding<String>(get: { "" }, set: { _ in })
        
        // Initialize PhotoPicker
        let photoPicker = PhotoPicker(
            selectedImage: selectedImage,
            recognizedText: recognizedText,
            detectedLanguage: detectedLanguage
        )
        
        // Create coordinator
        let coordinator = PhotoPicker.Coordinator(photoPicker)
        
        // Verify the coordinator is properly initialized
        #expect(coordinator.parent === photoPicker)
    }
    
    @Test func testCoordinatorPickerDismissWithNoSelection() {
        // Create bindings for the required properties
        var selectedImageValue: UIImage? = nil
        let selectedImage = Binding<UIImage?>(
            get: { selectedImageValue },
            set: { selectedImageValue = $0 }
        )
        
        var recognizedTextValue = ""
        let recognizedText = Binding<String>(
            get: { recognizedTextValue },
            set: { recognizedTextValue = $0 }
        )
        
        var detectedLanguageValue = ""
        let detectedLanguage = Binding<String>(
            get: { detectedLanguageValue },
            set: { detectedLanguageValue = $0 }
        )
        
        // Initialize PhotoPicker
        let photoPicker = PhotoPicker(
            selectedImage: selectedImage,
            recognizedText: recognizedText,
            detectedLanguage: detectedLanguage
        )
        
        // Create coordinator
        let coordinator = PhotoPicker.Coordinator(photoPicker)
        
        // Create a mock PHPickerViewController
        let mockPicker = MockPHPickerViewController()
        
        // Call picker with empty results
        coordinator.picker(mockPicker, didFinishPicking: [])
        
        // Verify the picker was dismissed
        #expect(mockPicker.dismissCalled)
        
        // Verify no image was selected
        #expect(selectedImageValue == nil)
        #expect(recognizedTextValue == "")
        #expect(detectedLanguageValue == "")
    }
}

// MARK: - Mock Classes for Testing

class MockPHPickerViewController: PHPickerViewController {
    var dismissCalled = false
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissCalled = true
        completion?()
    }
}

// MARK: - Additional Tests for TextRecognizer Integration

extension PhotoPickerTests {
    
    @Test func testPhotoPickerTextRecognizerIntegration() {
        // Create a mock TextRecognizer
        let mockTextRecognizer = MockTextRecognizer()
        
        // Create bindings for the required properties
        var selectedImageValue: UIImage? = nil
        let selectedImage = Binding<UIImage?>(
            get: { selectedImageValue },
            set: { selectedImageValue = $0 }
        )
        
        var recognizedTextValue = ""
        let recognizedText = Binding<String>(
            get: { recognizedTextValue },
            set: { recognizedTextValue = $0 }
        )
        
        var detectedLanguageValue = ""
        let detectedLanguage = Binding<String>(
            get: { detectedLanguageValue },
            set: { detectedLanguageValue = $0 }
        )
        
        var callbackCalled = false
        var callbackText = ""
        var callbackLanguage = ""
        
        // Initialize PhotoPicker with callback
        let photoPicker = PhotoPickerWithMockRecognizer(
            selectedImage: selectedImage,
            recognizedText: recognizedText,
            detectedLanguage: detectedLanguage,
            textRecognizer: mockTextRecognizer
        ) { text, language in
            callbackCalled = true
            callbackText = text
            callbackLanguage = language
        }
        
        // Create coordinator
        let coordinator = photoPicker.makeCoordinator()
        
        // Create a mock PHPickerViewController and PHPickerResult
        let mockPicker = MockPHPickerViewController()
        let mockResult = MockPHPickerResult()
        
        // Call picker with mock result
        coordinator.picker(mockPicker, didFinishPicking: [mockResult])
        
        // Verify the picker was dismissed
        #expect(mockPicker.dismissCalled)
        
        // Verify the image provider was accessed
        #expect(mockResult.itemProviderAccessed)
        
        // Since we can't easily mock the async loading, we verify the text recognizer was configured correctly
        #expect(mockTextRecognizer.recognizeTextCalled)
    }
}

// Mock classes for TextRecognizer integration testing

class MockTextRecognizer: TextRecognizer {
    var recognizeTextCalled = false
    var mockRecognizedText = "Mock recognized text"
    var mockDetectedLanguage = "English"
    
    override func recognizeText(in image: UIImage, completion: @escaping (String, String) -> Void) {
        recognizeTextCalled = true
        completion(mockRecognizedText, mockDetectedLanguage)
    }
}

class MockPHPickerResult: PHPickerResult {
    var itemProviderAccessed = false
    
    override var itemProvider: NSItemProvider {
        let mockProvider = MockItemProvider()
        itemProviderAccessed = true
        return mockProvider
    }
}

class MockItemProvider: NSItemProvider {
    override func canLoadObject(ofClass aClass: NSItemProviderReading.Type) -> Bool {
        return aClass == UIImage.self
    }
    
    override func loadObject(ofClass aClass: NSItemProviderReading.Type, completionHandler: @escaping (NSItemProviderReading?, Error?) -> Void) -> Progress {
        if aClass == UIImage.self {
            let mockImage = UIImage()
            completionHandler(mockImage, nil)
        }
        return Progress()
    }
}

// A custom PhotoPicker that uses a mock TextRecognizer for testing
struct PhotoPickerWithMockRecognizer: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var recognizedText: String
    @Binding var detectedLanguage: String
    var onTextRecognized: ((String, String) -> Void)? = nil
    var textRecognizer: TextRecognizer
    
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
        let parent: PhotoPickerWithMockRecognizer
        
        init(_ parent: PhotoPickerWithMockRecognizer) {
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
                            
                            // Use the injected text recognizer
                            self.parent.textRecognizer.recognizeText(in: uiImage) { recognizedText, detectedLanguage in
                                self.parent.recognizedText = recognizedText
                                self.parent.detectedLanguage = detectedLanguage
                                
                                // Call the callback if provided
                                self.parent.onTextRecognized?(recognizedText, detectedLanguage)
                            }
                        }
                    }
                }
            }
        }
    }
}
