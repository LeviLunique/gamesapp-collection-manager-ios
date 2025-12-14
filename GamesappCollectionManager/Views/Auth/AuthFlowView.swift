import SwiftUI

private enum AuthRoute: Hashable {
    case register
    case forgot
}

struct AuthFlowView: View {
    @ObservedObject var session: SessionViewModel
    @State private var path: [AuthRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            LoginScreen(
                session: session,
                onRegister: { path.append(.register) },
                onForgot: { path.append(.forgot) }
            )
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .register:
                    RegisterScreen(session: session)
                case .forgot:
                    ForgotPasswordScreen(session: session)
                }
            }
        }
    }
}

private struct LoginScreen: View {
    @ObservedObject var session: SessionViewModel
    let onRegister: () -> Void
    let onForgot: () -> Void
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Entrar")
                        .font(.largeTitle).bold()
                    Text("Acesse sua biblioteca de jogos")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                EmailField(title: "Email", text: $email)

                PasswordField(title: "Senha", text: $password)

                Button {
                    session.signIn(email: email, password: password)
                } label: {
                    HStack {
                        if session.isWorking { ProgressView() }
                        Text("Entrar")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(session.isWorking)

                VStack(spacing: 12) {
                    Button("Esqueci minha senha") {
                        onForgot()
                    }
                    .font(.callout)

                    HStack {
                        Text("Não tem conta?")
                        Button("Criar conta") {
                            onRegister()
                        }
                        .fontWeight(.semibold)
                    }
                    .font(.callout)
                }
                .foregroundStyle(.primary)
                .padding(.top, 8)
            }
            .padding()
        }
    }
}

private struct RegisterScreen: View {
    @ObservedObject var session: SessionViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirm = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Criar conta")
                        .font(.largeTitle).bold()
                    Text("Use um email válido e defina uma senha segura.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                EmailField(title: "Email", text: $email)

                PasswordField(title: "Senha (mín. 6)", text: $password)
                PasswordField(title: "Confirmar senha", text: $confirm)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Requisitos de senha")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("• Mínimo 6 caracteres")
                        .font(.caption2)
                        .foregroundStyle(password.count >= 6 ? .green : .secondary)
                    Text("• Confirmação deve coincidir")
                        .font(.caption2)
                        .foregroundStyle(password == confirm && !confirm.isEmpty ? .green : .secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    register()
                } label: {
                    HStack {
                        if session.isWorking { ProgressView() }
                        Text("Criar conta")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValid ? Color.accentColor : Color.accentColor.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!isValid || session.isWorking)
            }
            .padding()
        }
    }

    private var isValid: Bool {
        !email.isEmpty && password.count >= 6 && password == confirm
    }

    private func register() {
        guard isValid else { return }
        session.register(email: email, password: password)
    }
}

private struct ForgotPasswordScreen: View {
    @ObservedObject var session: SessionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""

    var body: some View {
        Form {
            Section {
                Text("Informe seu email para enviar o link de recuperação.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                EmailField(title: "Email", text: $email)
            }
        }
        .navigationTitle("Recuperar senha")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Enviar") {
                    session.sendPasswordReset(email: email)
                    dismiss()
                }
                .disabled(email.isEmpty)
            }
        }
    }
}
