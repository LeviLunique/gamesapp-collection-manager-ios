import SwiftUI

struct GameRow: View {
    let game: Game
    var showDivider: Bool = false
    private var statusColor: Color {
        switch game.status {
        case .backlog: return .gray
        case .playing: return .blue
        case .done: return .green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                CoverPreview(imageData: nil, existingPath: game.coverPath)
                    .frame(width: 70, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 8) {
                    Text(game.title)
                        .font(.headline)
                    Text(game.platform)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Text("Status")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Label(game.status.label, systemImage: game.status.icon)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(statusColor.opacity(0.12))
                                .foregroundStyle(statusColor)
                                .clipShape(Capsule())
                        }
                        HStack(spacing: 6) {
                            Text("Nota")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            StarRatingView(rating: game.rating)
                                .fixedSize()
                        }
                    }
                }
                Spacer()
            }
            if showDivider {
                Divider()
                    .padding(.top, 8)
            }
        }
        .padding(.vertical, 4)
    }
}
