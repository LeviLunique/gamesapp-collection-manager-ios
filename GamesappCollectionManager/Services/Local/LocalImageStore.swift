import Foundation

struct LocalImageStore: ImageStore {
    private let folder: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        folder = support.appendingPathComponent("covers", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        log("Using LocalImageStore (fallback) for images", category: .images, level: .info)
    }

    func save(imageData: Data, for userId: String, existingPath: String?) async throws -> String {
        if let existingPath {
            try? await delete(at: existingPath)
        }
        let filename = "\(userId)-\(UUID().uuidString).jpg"
        let url = folder.appendingPathComponent(filename)
        try imageData.write(to: url, options: .atomic)
        return url.path
    }

    func delete(at path: String) async throws {
        let url = URL(fileURLWithPath: path)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }
}
