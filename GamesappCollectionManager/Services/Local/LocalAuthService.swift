import Foundation

actor LocalAuthService: AuthService {
    private struct StoredUser: Codable {
        var id: String
        var email: String
        var password: String
    }

    private let storageURL: URL
    private let sessionKey = "LocalAuthCurrentUser"
    private var users: [StoredUser] = []
    private var currentUserId: String?

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = support.appendingPathComponent("auth", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        storageURL = folder.appendingPathComponent("users.json")
        users = (try? Data(contentsOf: storageURL)).flatMap { try? JSONDecoder().decode([StoredUser].self, from: $0) } ?? []
        currentUserId = UserDefaults.standard.string(forKey: sessionKey)
        log("Using LocalAuthService (fallback) for auth", category: .auth, level: .info)
    }

    func restore() async -> UserProfile? {
        guard let id = currentUserId, let user = users.first(where: { $0.id == id }) else { return nil }
        return UserProfile(id: user.id, email: user.email)
    }

    func signIn(email: String, password: String) async throws -> UserProfile {
        guard let user = users.first(where: { $0.email.caseInsensitiveCompare(email) == .orderedSame && $0.password == password }) else {
            throw AppError.invalidCredentials
        }
        currentUserId = user.id
        UserDefaults.standard.set(user.id, forKey: sessionKey)
        return UserProfile(id: user.id, email: user.email)
    }

    func register(email: String, password: String) async throws -> UserProfile {
        guard password.count >= 6 else { throw AppError.weakPassword }
        guard users.first(where: { $0.email.caseInsensitiveCompare(email) == .orderedSame }) == nil else {
            throw AppError.emailInUse
        }

        let newUser = StoredUser(id: UUID().uuidString, email: email.lowercased(), password: password)
        users.append(newUser)
        try persistUsers()
        currentUserId = newUser.id
        UserDefaults.standard.set(newUser.id, forKey: sessionKey)
        return UserProfile(id: newUser.id, email: newUser.email)
    }

    func sendPasswordReset(email: String) async throws {
        guard users.contains(where: { $0.email.caseInsensitiveCompare(email) == .orderedSame }) else {
            throw AppError.invalidCredentials
        }
    }

    func updateEmail(currentPassword: String, newEmail: String) async throws -> UserProfile {
        guard let id = currentUserId, let index = users.firstIndex(where: { $0.id == id }) else {
            throw AppError.invalidCredentials
        }
        guard users[index].password == currentPassword else { throw AppError.invalidCredentials }
        guard users.first(where: { $0.email.caseInsensitiveCompare(newEmail) == .orderedSame && $0.id != id }) == nil else {
            throw AppError.emailInUse
        }
        users[index].email = newEmail.lowercased()
        try persistUsers()
        return UserProfile(id: users[index].id, email: users[index].email)
    }

    func updatePassword(currentPassword: String, newPassword: String) async throws {
        guard newPassword.count >= 6 else { throw AppError.weakPassword }
        guard let id = currentUserId, let index = users.firstIndex(where: { $0.id == id }) else {
            throw AppError.invalidCredentials
        }
        guard users[index].password == currentPassword else { throw AppError.invalidCredentials }
        users[index].password = newPassword
        try persistUsers()
    }

    func deleteAccount(password: String) async throws {
        guard let id = currentUserId, let index = users.firstIndex(where: { $0.id == id }) else {
            throw AppError.invalidCredentials
        }
        guard users[index].password == password else { throw AppError.invalidCredentials }
        users.remove(at: index)
        try persistUsers()
        currentUserId = nil
        UserDefaults.standard.removeObject(forKey: sessionKey)
    }

    func signOut() async {
        currentUserId = nil
        UserDefaults.standard.removeObject(forKey: sessionKey)
    }

    private func persistUsers() throws {
        try FileManager.default.createDirectory(at: storageURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(users)
        try data.write(to: storageURL, options: .atomic)
    }
}
