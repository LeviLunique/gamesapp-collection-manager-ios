import SwiftUI
#if canImport(FirebaseCore)
import FirebaseCore
#endif

@main
struct GamesappCollectionManagerApp: App {
    init() {
        #if canImport(FirebaseCore)
        FirebaseApp.configure()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}
