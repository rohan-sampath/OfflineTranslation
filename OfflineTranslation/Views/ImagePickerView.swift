import SwiftUI

struct ImagePickerView: View {
    @Binding var selectedImage: UIImage?
    @Binding var isPickerPresented: Bool

    var body: some View {
        if let image = selectedImage {
            ZStack(alignment: .bottom) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.50)
                    .frame(maxWidth: .infinity, alignment: .center)

                // Buttons overlay
                HStack {
                    // "X" button to remove image (LHS) - changed to gray
                    Button(action: {
                        selectedImage = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .padding(12)
                            .background(Color.gray.opacity(0.6)) // Changed from red to gray
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                    .padding(.leading, 12)

                    Spacer()

                    // "Photo" button to re-select image (RHS)
                    Button(action: {
                        isPickerPresented = true
                    }) {
                        Image(systemName: "photo")
                            .font(.system(size: 22))
                            .padding(12)
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                    .padding(.trailing, 12)
                }
                .frame(maxWidth: .infinity)
            }
        } else {
            VStack {
                Text("Select an Image")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.vertical, 100)

                Button("Choose Image") {
                    isPickerPresented = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}
