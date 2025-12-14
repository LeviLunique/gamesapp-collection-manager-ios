import SwiftUI
import PhotosUI

struct GameFormView: View {
    @Binding var draft: GameDraft
    @Binding var imageData: Data?
    @Binding var removedCoverPath: String?
    let onSave: (GameDraft, Data?, String?) -> Void
    let onCancel: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        Form {
            Section("Informações") {
                TextField("Título", text: $draft.title)
                TextField("Plataforma", text: $draft.platform)
                Picker("Status", selection: $draft.status) {
                    ForEach(GameStatus.allCases) { status in
                        Text(status.label).tag(status)
                    }
                }
                Stepper(value: $draft.rating, in: 0...5, step: 1) {
                    HStack {
                        Text("Avaliação")
                        Spacer()
                        StarRatingView(rating: Int(draft.rating))
                    }
                }
                TextField("Notas", text: $draft.notes, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }

            Section("Capa") {
                CoverPreview(imageData: imageData, existingPath: draft.coverPath)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.secondary.opacity(0.2))
                    }

                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label("Escolher imagem", systemImage: "photo")
                }

                if draft.coverPath != nil || imageData != nil {
                    Button("Remover capa", role: .destructive) {
                        removedCoverPath = draft.coverPath
                        draft.coverPath = nil
                        imageData = nil
                    }
                }
            }
        }
        .navigationTitle(draft.isNew ? "Novo jogo" : "Editar jogo")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") {
                    onCancel()
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salvar") {
                    onSave(draft, imageData, removedCoverPath)
                    dismiss()
                }
                .disabled(!draft.isValid)
            }
        }
        .onChange(of: pickerItem) { newValue in
            guard let item = newValue else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        imageData = data
                        removedCoverPath = draft.coverPath
                    }
                }
            }
        }
    }
}
