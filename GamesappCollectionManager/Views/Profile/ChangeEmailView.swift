import SwiftUI

struct ChangeEmailView: View {
    @ObservedObject var session: SessionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var newEmail = ""
    @State private var currentPassword = ""

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirme sua senha para atualizar o email.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                EmailField(title: "Novo email", text: $newEmail)
                PasswordField(title: "Senha atual", text: $currentPassword)
            }

            Spacer()

            Button {
                session.updateEmail(currentPassword: currentPassword, newEmail: newEmail)
                dismiss()
            } label: {
                Text("Salvar")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValid ? Color.accentColor : Color.accentColor.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(!isValid)
        }
        .padding()
        .navigationTitle("Alterar email")
    }

    private var isValid: Bool {
        !newEmail.isEmpty && !currentPassword.isEmpty
    }
}
