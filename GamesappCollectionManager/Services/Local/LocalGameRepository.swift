import Foundation

actor LocalGameRepository: GameRepository {
    private let folder: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        folder = support.appendingPathComponent("games", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        log("Using LocalGameRepository (fallback) for games", category: .games, level: .info)
    }

    func loadAll(for userId: String) async throws -> [Game] {
        let url = fileURL(for: userId)
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Game].self, from: data)
    }

    func save(game: Game, for userId: String) async throws {
        var items = try await loadAll(for: userId)
        if let index = items.firstIndex(where: { $0.id == game.id }) {
            items[index] = game
        } else {
            items.append(game)
        }
        try persist(items, for: userId)
    }

    func delete(ids: [String], for userId: String) async throws {
        guard !ids.isEmpty else { return }
        var items = try await loadAll(for: userId)
        items.removeAll { ids.contains($0.id) }
        try persist(items, for: userId)
    }

    func wipe(for userId: String) async throws {
        let url = fileURL(for: userId)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    private func fileURL(for userId: String) -> URL {
        folder.appendingPathComponent("\(userId).json")
    }

    private func persist(_ games: [Game], for userId: String) throws {
        let url = fileURL(for: userId)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(games)
        try data.write(to: url, options: .atomic)
    }
}
