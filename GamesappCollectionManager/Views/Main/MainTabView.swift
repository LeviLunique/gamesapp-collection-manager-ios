import SwiftUI

struct MainTabView: View {
    let user: UserProfile
    @ObservedObject var session: SessionViewModel
    @ObservedObject var gamesVM: GameListViewModel

    var body: some View {
        TabView {
            GameListScreen(viewModel: gamesVM)
                .tabItem {
                    Label("Jogos", systemImage: "rectangle.stack")
                }

            ProfileScreen(user: user, session: session, gamesVM: gamesVM)
                .tabItem {
                    Label("Perfil", systemImage: "person.crop.circle")
                }
        }
    }
}
