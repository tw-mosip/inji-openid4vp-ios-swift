enum VerifierVerificationException: Error {
    case invalidClientId
    case clientIdNotFound
    case redirectUriIsEmpty
    case failedToVerifyClientId
}
