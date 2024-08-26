enum VerifierVerificationException: Error {
    case clientIdNotFound(message: String)
    case redirectUriIsEmpty
    
    var localizedDescription: String {
        switch self {
        case .clientIdNotFound(let message):
            return message
        default:
            return "An error occurred."
        }
    }
}
