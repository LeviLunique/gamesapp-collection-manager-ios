import SwiftUI

struct ChangePasswordView: View {
    @ObservedObject var session: SessionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Atualize sua senha com segurança.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                PasswordField(title: "Senha atual", text: $currentPassword)
                PasswordField(title: "Nova senha (mín. 6)", text: $newPassword)
                PasswordField(title: "Confirmar nova senha", text: $confirmPassword)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Requisitos")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("• Mínimo 6 caracteres")
                        .font(.caption2)
                        .foregroundStyle(newPassword.count >= 6 ? .green : .secondary)
                    Text("• Nova senha deve coincidir com a confirmação")
                        .font(.caption2)
                        .foregroundStyle((newPassword == confirmPassword && !newPassword.isEmpty) ? .green : .secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()

            Button {
                session.updatePassword(currentPassword: currentPassword, newPassword: newPassword)
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
        .navigationTitle("Alterar senha")
    }

    private var isValid: Bool {
        !currentPassword.isEmpty &&
        newPassword.count >= 6 &&
        newPassword == confirmPassword
    }
}
