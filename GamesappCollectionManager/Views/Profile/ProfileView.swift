import SwiftUI

struct ProfileScreen: View {
    let user: UserProfile
    @ObservedObject var session: SessionViewModel
    @ObservedObject var gamesVM: GameListViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Conta") {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(user.email)
                            .foregroundStyle(.secondary)
                    }
                    Button("Sair") {
                        session.signOut()
                    }
                }

                Section("Segurança") {
                    NavigationLink("Alterar email") {
                        ChangeEmailView(session: session)
                    }
                    NavigationLink("Alterar senha") {
                        ChangePasswordView(session: session)
                    }
                }

                Section("Recuperação") {
                    Button("Enviar email de recuperação") {
                        session.sendPasswordReset(email: user.email)
                    }
                }

                Section("Excluir conta") {
                    NavigationLink {
                        DeleteAccountView(session: session, gamesVM: gamesVM)
                    } label: {
                        Text("Excluir conta e dados")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Perfil")
        }
    }
}
