import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore

final class FirebaseGameRepository: GameRepository {
    private let db = Firestore.firestore()

    init() {
        log("Using FirebaseGameRepository for games", category: .games, level: .info)
    }

    func loadAll(for userId: String) async throws -> [Game] {
        let snapshot = try await db.collection("users").document(userId).collection("games").getDocuments()
        log("FirebaseGameRepository.loadAll count: \(snapshot.documents.count)", category: .games, level: .info)
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            let title = data["title"] as? String ?? ""
            let platform = data["platform"] as? String ?? ""
            let statusRaw = data["status"] as? String ?? GameStatus.backlog.rawValue
            let rating = data["rating"] as? Int ?? 0
            let notes = data["notes"] as? String ?? ""
            let cover = data["coverPath"] as? String
            let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
            guard let status = GameStatus(rawValue: statusRaw) else { return nil }
            return Game(id: doc.documentID, title: title, platform: platform, status: status, rating: rating, notes: notes, coverPath: cover, updatedAt: updatedAt)
        }
    }

    func save(game: Game, for userId: String) async throws {
        let payload: [String: Any] = [
            "title": game.title,
            "platform": game.platform,
            "status": game.status.rawValue,
            "rating": game.rating,
            "notes": game.notes,
            "coverPath": game.coverPath as Any,
            "updatedAt": Timestamp(date: game.updatedAt)
        ]
        try await db.collection("users").document(userId).collection("games").document(game.id).setData(payload, merge: true)
        log("FirebaseGameRepository.save gameId: \(game.id)", category: .games, level: .info)
    }

    func delete(ids: [String], for userId: String) async throws {
        guard !ids.isEmpty else { return }
        for id in ids {
            try await db.collection("users").document(userId).collection("games").document(id).delete()
            log("FirebaseGameRepository.delete gameId: \(id)", category: .games, level: .info)
        }
    }

    func wipe(for userId: String) async throws {
        let collection = db.collection("users").document(userId).collection("games")
        let snapshot = try await collection.getDocuments()
        for doc in snapshot.documents {
            try await doc.reference.delete()
            log("FirebaseGameRepository.wipe deleted \(doc.documentID)", category: .games, level: .info)
        }
    }
}
#endif
