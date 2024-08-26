enum AuthorizationResponseException: Error {
    case credentialsMapIsEmpty
    case credentialsMapValueIsEmpty
    case jsonEncodingException(fieldName: String)
    case invalidURL
    
    var localizedDescription: String {
        switch self {
        case .jsonEncodingException(let fieldName):
            return "Error occurred while serializing \(fieldName)"
        default:
            return "An error occurred."
        }
    }
}
