import Foundation

enum SortKey: String, CaseIterable, Identifiable {
    case title, platform, status, updatedAt

    var id: String { rawValue }

    var label: String {
        switch self {
        case .title: return "Nome"
        case .platform: return "Plataforma"
        case .status: return "Status"
        case .updatedAt: return "Recentes"
        }
    }
}
