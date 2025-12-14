import Foundation

struct Game: Identifiable, Codable, Equatable {
    var id: String
    var title: String
    var platform: String
    var status: GameStatus
    var rating: Int
    var notes: String
    var coverPath: String?
    var updatedAt: Date
}

extension Game {
    var draft: GameDraft {
        GameDraft(
            id: id,
            title: title,
            platform: platform,
            status: status,
            rating: Double(rating),
            notes: notes,
            coverPath: coverPath
        )
    }
}
