import Foundation
import SwiftUI

@MainActor
final class SessionViewModel: ObservableObject {
    enum AuthState: Equatable {
        case loading
        case signedOut
        case signedIn(UserProfile)
    }

    @Published var authState: AuthState = .loading
    @Published var message: String?
    @Published var isWorking = false

    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
        Task {
            await restore()
        }
    }

    var currentUser: UserProfile? {
        if case .signedIn(let user) = authState {
            return user
        }
        return nil
    }

    func restore() async {
        let user = await authService.restore()
        if let user {
            authState = .signedIn(user)
        } else {
            authState = .signedOut
        }
    }

    func signIn(email: String, password: String) {
        run { [weak self] in
            guard let self else { return }
            let user = try await self.authService.signIn(email: email, password: password)
            self.authState = .signedIn(user)
        }
    }

    func register(email: String, password: String) {
        run { [weak self] in
            guard let self else { return }
            let user = try await self.authService.register(email: email, password: password)
            self.authState = .signedIn(user)
        }
    }

    func sendPasswordReset(email: String) {
        run { [weak self] in
            guard let self else { return }
            try await self.authService.sendPasswordReset(email: email)
            self.message = "Se o email estiver cadastrado, enviaremos o link de recuperação."
        }
    }

    func updateEmail(currentPassword: String, newEmail: String) {
        run { [weak self] in
            guard let self else { return }
            guard case .signedIn = self.authState else { throw AppError.invalidCredentials }
            let user = try await self.authService.updateEmail(currentPassword: currentPassword, newEmail: newEmail)
            self.authState = .signedIn(user)
            self.message = "Email atualizado com sucesso."
        }
    }

    func updatePassword(currentPassword: String, newPassword: String) {
        run { [weak self] in
            guard let self else { return }
            try await self.authService.updatePassword(currentPassword: currentPassword, newPassword: newPassword)
            self.message = "Senha alterada."
        }
    }

    func deleteAccount(password: String, afterDeletingData: @escaping () async -> Void) {
        run { [weak self] in
            guard let self else { return }
            try await self.authService.deleteAccount(password: password)
            await afterDeletingData()
            self.authState = .signedOut
            self.message = "Conta excluída."
        }
    }

    func signOut() {
        Task {
            await self.authService.signOut()
            await MainActor.run {
                self.authState = .signedOut
            }
        }
    }

    private func run(_ work: @escaping () async throws -> Void) {
        isWorking = true
        Task { [weak self] in
            guard let self else { return }
            do {
                try await work()
            } catch {
                await MainActor.run {
                    self.message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                }
            }
            await MainActor.run {
                self.isWorking = false
            }
        }
    }
}
