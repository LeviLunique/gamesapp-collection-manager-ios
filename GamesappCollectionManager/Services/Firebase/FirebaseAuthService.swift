import Foundation
#if canImport(FirebaseAuth)
import FirebaseAuth

final class FirebaseAuthService: AuthService {
    init() {
        log("Using FirebaseAuthService for auth", category: .auth, level: .info)
    }

    func restore() async -> UserProfile? {
        guard let user = Auth.auth().currentUser else { return nil }
        log("FirebaseAuthService.restore -> user: \(user.uid)", category: .auth, level: .info)
        return UserProfile(id: user.uid, email: user.email ?? "")
    }

    func signIn(email: String, password: String) async throws -> UserProfile {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let user = result.user
        log("FirebaseAuthService.signIn success uid: \(user.uid)", category: .auth, level: .info)
        return UserProfile(id: user.uid, email: user.email ?? email)
    }

    func register(email: String, password: String) async throws -> UserProfile {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let user = result.user
        log("FirebaseAuthService.register success uid: \(user.uid)", category: .auth, level: .info)
        return UserProfile(id: user.uid, email: user.email ?? email)
    }

    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
        log("FirebaseAuthService.sendPasswordReset sent to \(email)", category: .auth, level: .info)
    }

    func updateEmail(currentPassword: String, newEmail: String) async throws -> UserProfile {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            throw AppError.invalidCredentials
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        try await user.reauthenticate(with: credential)
        try await user.updateEmail(to: newEmail)
        return UserProfile(id: user.uid, email: newEmail)
    }

    func updatePassword(currentPassword: String, newPassword: String) async throws {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            throw AppError.invalidCredentials
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        try await user.reauthenticate(with: credential)
        try await user.updatePassword(to: newPassword)
    }

    func deleteAccount(password: String) async throws {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            throw AppError.invalidCredentials
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.reauthenticate(with: credential)
        try await user.delete()
    }

    func signOut() async {
        try? Auth.auth().signOut()
    }
}
#endif
