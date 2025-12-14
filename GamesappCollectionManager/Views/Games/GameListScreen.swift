import SwiftUI
import PhotosUI

struct GameListScreen: View {
    @ObservedObject var viewModel: GameListViewModel

    @State private var editMode: EditMode = .inactive
    @State private var draft = GameDraft()
    @State private var imageData: Data?
    @State private var removedCoverPath: String?
    @State private var presentingEditor = false
    private var isEditing: Bool { editMode == .active }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filters

                List(selection: $viewModel.selection) {
                    let games = viewModel.filteredGames
                    ForEach(Array(games.enumerated()), id: \.element.id) { index, game in
                        GameRow(game: game, showDivider: index < games.count - 1)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                guard editMode != .active else { return }
                                openEditor(for: game)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.delete(game)
                                } label: {
                                    Label("Excluir", systemImage: "trash")
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 0, trailing: 12))
                    }
                }
                .animation(.easeInOut, value: viewModel.filteredGames)
                .overlay {
                    if viewModel.isLoading {
                        ProgressView("Carregando jogos...")
                    } else if viewModel.filteredGames.isEmpty {
                        ContentUnavailableView("Nenhum jogo encontrado", systemImage: "gamecontroller", description: Text("Adicione seu primeiro jogo ou ajuste os filtros."))
                    }
                }
                .searchable(text: $viewModel.search, prompt: "Buscar por nome ou plataforma")
                .refreshable { await viewModel.loadGames() }
            }
            .navigationTitle("Jogos")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if !viewModel.filteredGames.isEmpty {
                        EditButton()
                            .environment(\.editMode, $editMode)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button(action: toggleSelection) {
                            Text(selectionLabel)
                        }
                    }
                    if !viewModel.selection.isEmpty {
                        Button(role: .destructive) {
                            viewModel.deleteSelection()
                        } label: {
                            Label("Excluir", systemImage: "trash")
                        }
                    }
                    if !isEditing {
                        Button(action: newGame) {
                            Label("Novo", systemImage: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $presentingEditor) {
                NavigationStack {
                    GameFormView(
                        draft: $draft,
                        imageData: $imageData,
                        removedCoverPath: $removedCoverPath,
                        onSave: { updatedDraft, data, removedPath in
                            viewModel.save(draft: updatedDraft, imageData: data, removedCoverPath: removedPath)
                            resetEditor()
                        },
                        onCancel: resetEditor
                    )
                }
            }
            .environment(\.editMode, $editMode)
        }
    }

    private var filters: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Menu {
                        Button("Todos") { viewModel.statusFilter = nil }
                        ForEach(GameStatus.allCases) { status in
                            Button(status.label) { viewModel.statusFilter = status }
                        }
                    } label: {
                        Label(viewModel.statusFilter?.label ?? "Status", systemImage: "line.3.horizontal.decrease.circle")
                    }

                    Menu {
                        ForEach(SortKey.allCases) { key in
                            Button(key.label) { viewModel.sortKey = key }
                        }
                    } label: {
                        Label(viewModel.sortKey.label, systemImage: "arrow.up.arrow.down.circle")
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }

    private func newGame() {
        draft = GameDraft()
        imageData = nil
        removedCoverPath = nil
        presentingEditor = true
    }

    private func openEditor(for game: Game) {
        draft = game.draft
        imageData = nil
        removedCoverPath = nil
        presentingEditor = true
    }

    private func resetEditor() {
        presentingEditor = false
        imageData = nil
        removedCoverPath = nil
    }

    private var selectionLabel: String {
        viewModel.selection.count == viewModel.filteredGames.count ? "Limpar seleção" : "Selecionar tudo"
    }

    private var selectionIcon: String {
        viewModel.selection.count == viewModel.filteredGames.count ? "xmark.circle" : "checkmark.circle"
    }

    private func toggleSelection() {
        let allIds = Set(viewModel.filteredGames.map { $0.id })
        if viewModel.selection == allIds {
            viewModel.selection.removeAll()
        } else {
            viewModel.selection = allIds
        }
    }
}
