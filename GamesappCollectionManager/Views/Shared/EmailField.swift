import SwiftUI

struct EmailField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = "email@exemplo.com"

    var body: some View {
        TextField(
            title,
            text: $text,
            prompt: Text(placeholder).foregroundStyle(.secondary)
        )
        .textContentType(.emailAddress)
        .keyboardType(.emailAddress)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}
