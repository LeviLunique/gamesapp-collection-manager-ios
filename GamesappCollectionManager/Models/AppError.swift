import Foundation

enum AppError: LocalizedError {
    case invalidCredentials
    case emailInUse
    case weakPassword
    case missingFields
    case gameNotFound
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Email ou senha inválidos."
        case .emailInUse:
            return "Já existe uma conta com este email."
        case .weakPassword:
            return "A senha precisa ter pelo menos 6 caracteres."
        case .missingFields:
            return "Preencha todos os campos obrigatórios."
        case .gameNotFound:
            return "Jogo não encontrado."
        case .unknown(let message):
            return message
        }
    }
}
