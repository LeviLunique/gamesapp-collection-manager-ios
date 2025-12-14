import Foundation
#if canImport(FirebaseStorage)
import FirebaseStorage

struct FirebaseImageStore: ImageStore {
    private let storage = Storage.storage()
    init() {
        log("Using FirebaseImageStore for images", category: .images, level: .info)
    }

    func save(imageData: Data, for userId: String, existingPath: String?) async throws -> String {
        if let existingPath {
            try? await deleteRemote(path: existingPath)
        }
        let path = "users/\(userId)/covers/\(UUID().uuidString).jpg"
        let ref = storage.reference(withPath: path)
        _ = try await ref.putDataAsync(imageData)
        let url = try await ref.downloadURL()
        log("FirebaseImageStore.save uploaded to \(path)", category: .images, level: .info)
        return url.absoluteString
    }

    func delete(at path: String) async throws {
        if let url = URL(string: path), url.scheme?.hasPrefix("http") == true {
            let ref = storage.reference(forURL: path)
            try await ref.delete()
            log("FirebaseImageStore.delete remote url \(path)", category: .images, level: .info)
        } else {
            try await deleteRemote(path: path)
        }
    }

    private func deleteRemote(path: String) async throws {
        let ref = storage.reference(forURL: path)
        try await ref.delete()
    }
}
#endif
