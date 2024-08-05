enum AuthorizationResponseErrors: Error {
    case credentialsMapIsEmpty
    case credentialsMapValueIsEmpty
    case vpTokenEnodingFailed
    case vpCreationFailed
    case encodingToJsonStringFailed
    case invalidURL
}
