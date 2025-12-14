import Foundation

struct GameDraft: Identifiable, Equatable {
    var id: String?
    var title: String = ""
    var platform: String = ""
    var status: GameStatus = .backlog
    var rating: Double = 3
    var notes: String = ""
    var coverPath: String?

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !platform.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isNew: Bool { id == nil }
}
