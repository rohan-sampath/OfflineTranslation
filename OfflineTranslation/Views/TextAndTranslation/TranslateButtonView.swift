import SwiftUI

struct TranslateButtonView: View {
    let isDisabled: Bool
    let action: () -> Void
    let errorMessage: String
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
                    .frame(width: 80, height: 40)
                
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
            Alert(
                title: Text("Translation Unavailable"), 
                message: Text(errorMessage.isEmpty ? "The selected language pair is not supported for translation." : errorMessage), 
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
