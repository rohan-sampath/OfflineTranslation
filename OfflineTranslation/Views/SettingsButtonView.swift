import SwiftUI

struct SettingsButtonView: View {
    @Binding var isSettingsPresented: Bool
    
    var body: some View {
        Button {
            isSettingsPresented = true
        } label: {
            Image(systemName: "gear")
        }
    }
}