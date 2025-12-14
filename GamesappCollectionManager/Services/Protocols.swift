import Foundation

protocol AuthService: Sendable {
    func restore() async -> UserProfile?
    func signIn(email: String, password: String) async throws -> UserProfile
    func register(email: String, password: String) async throws -> UserProfile
    func sendPasswordReset(email: String) async throws
    func updateEmail(currentPassword: String, newEmail: String) async throws -> UserProfile
    func updatePassword(currentPassword: String, newPassword: String) async throws
    func deleteAccount(password: String) async throws
    func signOut() async
}

protocol GameRepository: Sendable {
    func loadAll(for userId: String) async throws -> [Game]
    func save(game: Game, for userId: String) async throws
    func delete(ids: [String], for userId: String) async throws
    func wipe(for userId: String) async throws
}

protocol ImageStore: Sendable {
    func save(imageData: Data, for userId: String, existingPath: String?) async throws -> String
    func delete(at path: String) async throws
}
