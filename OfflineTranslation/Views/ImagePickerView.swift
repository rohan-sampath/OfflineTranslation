//
//  ImagePickerView.swift
//  OfflineTranslation
//
//  Created by Rohan Sampath on 3/10/25.
//
import SwiftUI

struct ImagePickerView: View {
    @Binding var selectedImage: UIImage?
    @Binding var isPickerPresented: Bool
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.50)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Text("Select an Image")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.vertical, 100)
            }
            
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
            .padding(12)
        }
    }
}
