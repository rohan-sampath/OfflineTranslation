# 📱 Offline Image-to-Text Translation App (iOS)

A Swift-based mobile app for iOS that performs **offline image-to-text translation** entirely using **locally deployed models**.

This project compares CoreML pipelines with custom **multimodal architectures** to extract and translate text from images without any server-side components or internet access.

---

## 🚀 Key Features

- 📸 **Camera & Photo Support** – Select or capture an image from your device.
- 🧠 **On-Device Text Detection** – Extracts text using local models with no external API calls.
- 🌍 **Offline Translation** – Translates text to English using small, efficient translation models.
- 🧬 **Multimodal Architecture** – Improves robustness and quality in noisy or low-light images.
- 🗣 **Low-Resource Language Support** – Delivers strong performance even in languages not well-supported by commercial apps.

---

## 🔍 Core Findings

- ✅ **Better Accuracy**: Using a locally deployed multimodal model significantly improves both text recognition and translation quality compared to traditional CoreML pipelines.
- 🌐 **Enhanced Language Coverage**: Outperforms the Apple Translate app when handling **low-resource languages** or regional scripts.

---

## 🧰 Tech Stack

- **Language**: Swift
- **Frameworks**: UIKit, CoreML, Vision, Natural Language
- **ML Models**: Custom multimodal transformer-based models deployed with CoreML
- **Platform**: iOS 16+

---

## 📦 Future Enhancements

- Add support for more target languages
- Improve bounding box visualization
- Batch processing for multiple images
- Evaluate quantized models for faster inference on older devices

---

## 📄 License

MIT License. See [LICENSE](./LICENSE) for details.

---

## 🙌 Acknowledgements

Inspired by advances in local LLM deployment, multimodal vision-language models, and the need for reliable translation tools in offline or privacy-sensitive contexts.
