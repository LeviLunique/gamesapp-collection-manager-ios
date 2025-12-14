import SwiftUI
import UIKit

struct CoverPreview: View {
    let imageData: Data?
    let existingPath: String?

    var body: some View {
        if let data = imageData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else if let path = existingPath, let url = URL(string: path), url.scheme?.hasPrefix("http") == true {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure(_):
                    placeholder
                case .empty:
                    placeholder.overlay {
                        ProgressView()
                    }
                @unknown default:
                    placeholder
                }
            }
        } else if let path = existingPath, let image = UIImage(contentsOfFile: path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(colors: [.purple.opacity(0.4), .blue.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: "photo")
                .font(.title)
                .foregroundStyle(.white.opacity(0.8))
        }
    }
}
