enum NetworkRequestException: Error {
    case invalidResponse
    case networkRequestFailed(message: String)
    case interruptedIOException
    
    var localizedDescription: String {
        switch self {
        case .networkRequestFailed(let message):
            return message
        default:
            return "An error occurred."
        }
    }
}
