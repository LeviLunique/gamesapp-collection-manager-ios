import Foundation

enum GameStatus: String, CaseIterable, Codable, Identifiable {
    case backlog = "BACKLOG"
    case playing = "PLAYING"
    case done = "DONE"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .backlog: return "Backlog"
        case .playing: return "Jogando"
        case .done: return "Concluído"
        }
    }

    var icon: String {
        switch self {
        case .backlog: return "tray"
        case .playing: return "gamecontroller"
        case .done: return "checkmark.circle"
        }
    }
}
