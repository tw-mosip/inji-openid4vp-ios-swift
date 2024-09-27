enum VerifierVerificationException: Error {
    case invalidVerifierClientID(message: String)
    case redirectUriIsEmpty
    
    var localizedDescription: String {
        switch self {
        case .invalidVerifierClientID(let message):
            return message
        default:
            return "An error occurred."
        }
    }
}