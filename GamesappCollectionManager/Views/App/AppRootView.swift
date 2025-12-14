import SwiftUI

struct AppRootView: View {
    @StateObject private var session = SessionViewModel(authService: ServiceFactory.makeAuthService())
    @StateObject private var gameList = GameListViewModel(
        repository: ServiceFactory.makeRepository(),
        imageStore: ServiceFactory.makeImageStore()
    )
    @State private var alertMessage: String?

    var body: some View {
        Group {
            switch session.authState {
            case .loading:
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Carregando...")
                        .font(.headline)
                }
            case .signedOut:
                AuthFlowView(session: session)
            case .signedIn(let user):
                MainTabView(user: user, session: session, gamesVM: gameList)
            }
        }
        .onChange(of: session.authState) { newValue in
            switch newValue {
            case .signedIn(let user):
                gameList.configure(user: user)
            case .signedOut:
                gameList.configure(user: nil)
            case .loading:
                break
            }
        }
        .onChange(of: session.message) { newValue in
            alertMessage = newValue
        }
        .onChange(of: gameList.message) { newValue in
            alertMessage = newValue
        }
        .alert(alertMessage ?? "", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) { alertMessage = nil }
        }
    }
}
