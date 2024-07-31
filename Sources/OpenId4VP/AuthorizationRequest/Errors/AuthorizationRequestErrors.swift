enum AuthorizationRequestErrors: Error {
    case invalidAuthorizationRequest
    case invalidVerifierList
    case noTrustedVerifiersFound
    case clientVerificationFailed
    case jsonDecodingFailed
    case unexpectedFormat
    case invalidPresentationDefinition
}

enum AuthorizationRequestParseError: Error {
    case decodingFailed
    case urlCreationFailed
    case queryItemsRetrievalFailed
    case invalidParameters
    case someParametersAreEmpty
}

enum VerifierVerificationError: Error {
    case invalidClientId
    case clientIdNotFound
    case missingRedirectUri
    case failedToVerifyClientId
}
