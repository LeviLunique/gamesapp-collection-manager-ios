import Foundation
import SwiftUI

@MainActor
final class GameListViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var isLoading = false
    @Published var statusFilter: GameStatus? = nil
    @Published var sortKey: SortKey = .title
    @Published var search = ""
    @Published var selection = Set<String>()
    @Published var message: String?

    private let repository: GameRepository
    private let imageStore: ImageStore
    private var userId: String?

    init(repository: GameRepository, imageStore: ImageStore) {
        self.repository = repository
        self.imageStore = imageStore
    }

    func configure(user: UserProfile?) {
        userId = user?.id
        games = []
        selection.removeAll()
        if user != nil {
            Task { await loadGames() }
        }
    }

    func loadGames() async {
        guard let userId else { return }
        isLoading = true
        do {
            let items = try await repository.loadAll(for: userId)
            await MainActor.run {
                games = items
            }
        } catch {
            await MainActor.run {
                message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
        }
        await MainActor.run {
            isLoading = false
        }
    }

    var filteredGames: [Game] {
        let base = games
            .filter { game in
                if let statusFilter, game.status != statusFilter { return false }
                if search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return true }
                let token = search.lowercased()
                return game.title.lowercased().contains(token) || game.platform.lowercased().contains(token)
            }

        let sorted: [Game]
        switch sortKey {
        case .title:
            sorted = base.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .platform:
            sorted = base.sorted { $0.platform.localizedCaseInsensitiveCompare($1.platform) == .orderedAscending }
        case .status:
            sorted = base.sorted { $0.status.rawValue < $1.status.rawValue }
        case .updatedAt:
            sorted = base.sorted { $0.updatedAt > $1.updatedAt }
        }
        return sorted
    }

    func save(draft: GameDraft, imageData: Data?, removedCoverPath: String? = nil) {
        guard let userId else { return }
        isLoading = true
        Task {
            do {
                var coverPath = draft.coverPath
                if let removedCoverPath {
                    try? await imageStore.delete(at: removedCoverPath)
                    coverPath = nil
                }
                if let data = imageData {
                    coverPath = try await imageStore.save(imageData: data, for: userId, existingPath: draft.coverPath)
                }
                let game = Game(
                    id: draft.id ?? UUID().uuidString,
                    title: draft.title.trimmingCharacters(in: .whitespacesAndNewlines),
                    platform: draft.platform.trimmingCharacters(in: .whitespacesAndNewlines),
                    status: draft.status,
                    rating: Int(draft.rating.rounded()),
                    notes: draft.notes.trimmingCharacters(in: .whitespacesAndNewlines),
                    coverPath: coverPath,
                    updatedAt: Date()
                )
                try await repository.save(game: game, for: userId)
                await loadGames()
            } catch {
                await MainActor.run {
                    message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    func delete(_ game: Game) {
        delete(ids: [game.id], coverPaths: [game.coverPath].compactMap { $0 })
    }

    func deleteSelection() {
        let ids = Array(selection)
        let covers = games.filter { selection.contains($0.id) }.compactMap { $0.coverPath }
        selection.removeAll()
        delete(ids: ids, coverPaths: covers)
    }

    func wipeAll() async {
        guard let userId else { return }
        do {
            for game in games {
                if let path = game.coverPath {
                    try? await imageStore.delete(at: path)
                }
            }
            try await repository.wipe(for: userId)
            await MainActor.run {
                games = []
            }
        } catch {
            await MainActor.run {
                message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
        }
    }

    private func delete(ids: [String], coverPaths: [String]) {
        guard let userId, !ids.isEmpty else { return }
        Task {
            for path in coverPaths {
                try? await imageStore.delete(at: path)
            }
            do {
                try await repository.delete(ids: ids, for: userId)
                await loadGames()
            } catch {
                await MainActor.run {
                    message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                }
            }
        }
    }
}
