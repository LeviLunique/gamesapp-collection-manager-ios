import SwiftUI

struct StarRatingView: View {
    let rating: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: index < rating ? "star.fill" : "star")
                    .foregroundColor(.yellow)
            }
        }
        .font(.caption)
    }
}
