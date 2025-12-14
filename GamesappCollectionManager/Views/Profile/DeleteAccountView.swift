import SwiftUI

struct DeleteAccountView: View {
    @ObservedObject var session: SessionViewModel
    @ObservedObject var gamesVM: GameListViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var password = ""
    @State private var confirmDialog = false

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Excluir conta")
                            .font(.headline)
                        Text("Esta ação é permanente e remove todos os seus jogos e capas.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label("Todos os jogos serão apagados", systemImage: "trash")
                        .foregroundColor(.secondary)
                    Label("Imagens de capa serão removidas", systemImage: "photo")
                        .foregroundColor(.secondary)
                    Label("A operação não pode ser desfeita", systemImage: "lock.shield")
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 12) {
                Text("Confirme sua senha")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                PasswordField(title: "Senha", text: $password)
            }

            Spacer()

            Button(role: .destructive) {
                confirmDialog = true
            } label: {
                Text("Excluir conta e dados")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.12))
                    .cornerRadius(12)
            }
            .disabled(password.isEmpty)
        }
        .padding()
        .navigationTitle("Excluir conta")
        .confirmationDialog(
            "Confirmar exclusão",
            isPresented: $confirmDialog,
            titleVisibility: .visible
        ) {
            Button("Excluir", role: .destructive) {
                session.deleteAccount(password: password) {
                    await gamesVM.wipeAll()
                }
                dismiss()
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Esta ação é permanente e não pode ser desfeita.")
        }
    }
}
