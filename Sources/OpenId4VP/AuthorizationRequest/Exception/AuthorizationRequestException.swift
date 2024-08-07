enum AuthorizationRequestException: Error, Equatable {
    case jsonDecodingFailed
    case invalidPresentationDefinition
    case invalidInput(key: String)
    case missingInput(fieldName: String)
    case decodingFailed
    case urlCreationFailed
    case queryItemsRetrievalFailed
    case parameterValuesAreEmpty
    
    var localizedDescription: String {
        switch self {
        case .invalidInput(let key):
            return "Invalid input for key : \(key)"
        case .missingInput(let fieldName):
            return "Missing Input: \(fieldName) is required."
        default:
            return "An error occurred."
        }
    }
}
