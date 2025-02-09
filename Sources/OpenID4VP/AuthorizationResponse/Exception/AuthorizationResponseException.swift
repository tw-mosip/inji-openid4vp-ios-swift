import Foundation

enum AuthorizationResponseException: Error, LocalizedError, Equatable {
    case credentialsMapIsEmpty
    case credentialsMapValueIsEmpty
    case jsonEncodingException(fieldName: String)
    case invalidURL
    case unknown
    case unsupportedFormatOfLibrary
    case unsupportedResponseType
    case unsupportedResponseMode
    
    public var errorDescription: String? {
        switch self {
        case .jsonEncodingException(let fieldName):
            return "Error occurred while serializing \(fieldName)"
        default:
            return "An error occurred."
        }
    }
}
