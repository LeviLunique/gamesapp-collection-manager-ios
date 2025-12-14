import Foundation

enum ServiceFactory {
    static func makeAuthService() -> AuthService {
        #if canImport(FirebaseAuth)
        log("ServiceFactory: FirebaseAuthService selected", category: .factory, level: .info)
        return FirebaseAuthService()
        #else
        log("ServiceFactory: LocalAuthService selected (FirebaseAuth not available)", category: .factory, level: .info)
        return LocalAuthService()
        #endif
    }

    static func makeRepository() -> GameRepository {
        #if canImport(FirebaseFirestore)
        log("ServiceFactory: FirebaseGameRepository selected", category: .factory, level: .info)
        return FirebaseGameRepository()
        #else
        log("ServiceFactory: LocalGameRepository selected (FirebaseFirestore not available)", category: .factory, level: .info)
        return LocalGameRepository()
        #endif
    }

    static func makeImageStore() -> ImageStore {
        #if canImport(FirebaseStorage)
        log("ServiceFactory: FirebaseImageStore selected", category: .factory, level: .info)
        return FirebaseImageStore()
        #else
        log("ServiceFactory: LocalImageStore selected (FirebaseStorage not available)", category: .factory, level: .info)
        return LocalImageStore()
        #endif
    }
}
