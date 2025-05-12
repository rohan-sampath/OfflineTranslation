# 📱 Offline Image-to-Text Translation App (iOS)

A Swift-based mobile app for iOS that performs **offline image-to-text translation** entirely using **locally deployed models**.

This project compares CoreML pipelines with custom **multimodal architectures** to extract and translate text from images without any server-side components or internet access.

---

## 🚀 Key Features

- 📸 **Camera & Photo Support** – Select or capture an image from your device.
- 🧠 **On-Device Text Detection** – Extracts text using local models with no external API calls.
- 🌍 **Offline Translation** – Translates text to a language of your choice using small, efficient translation models.
- 🧬 **Multimodal Architecture** – Improves robustness and quality in noisy or low-light images.
  
---

## 🔍 Core Findings

- ✅ **Better Accuracy**: Using a locally deployed multimodal model has improves both text recognition and translation quality compared to an Apple-only, traditional CoreML pipeline.
  
---

## 🧰 Tech Stack

- **Language**: Swift
- **Frameworks**: UIKit, CoreML, Vision, Natural Language
- **ML Models**: Custom multimodal transformer-based models deployed with CoreML
- **Platform**: iOS 16+

---

## 📦 Future Enhancements

- Add tokenization and other support for low-resource languages
- Add in-place translation with bounding boxes
- Batch processing for multiple images
- Evaluate quantized models for faster inference, particularly on older devices

---
