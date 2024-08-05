enum AuthenticationResponseErrors: Error {
    case invalidAuthorizationRequest
    case invalidVerifierList
    case noTrustedVerifiersFound
    case clientVerificationFailed
    case jsonDecodingFailed
    case unexpectedFormat
    case invalidPresentationDefinition
}

enum VerifierVerificationError: Error {
    case invalidClientId
    case clientIdNotFound
    case redirectUriIsEmpty
    case failedToVerifyClientId
}
