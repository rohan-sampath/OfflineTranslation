import SwiftUI

struct TranslateButtonView: View {
    let isDisabled: Bool
    let action: () -> Void
    @State private var showAlert: Bool = false

    var body: some View {
        Button(action: {
            if isDisabled {
                showAlert = true
            } else {
                action()
            }
        }) {
            ZStack {
                Capsule()
                    .fill(isDisabled ? Color.gray : Color.blue)
                    .frame(width: 100, height: 56)
                
                HStack(spacing: 4) {
                    Image(systemName: "globe")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Image(systemName: "arrow.right")
                        .resizable()
                        .frame(width: 12, height: 12)
                }
                .foregroundColor(.white)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Translation Unavailable"), message: Text("The selected language pair is not supported for translation."), dismissButton: .default(Text("OK")))
        }
    }
}
