enum AuthorizationRequestException: Error, Equatable {
    case jsonDecodingFailed
    case invalidPresentationDefinition
    case invalidQueryParams(message: String)
    case invalidInput(fieldName: String)
    case missingInput(fieldName: String)
    case decodingException
    case urlCreationFailed
    case queryItemsRetrievalFailed
    case parameterValuesAreEmpty
    
    var localizedDescription: String {
        switch self {
        case .invalidInput(let fieldName):
            return "Invalid input for key : \(fieldName)"
        case .missingInput(let fieldName):
            return "Missing Input: \(fieldName) param is required."
        case .invalidQueryParams(let message):
            return message
        default:
            return "An error occurred."
        }
    }
}