enum AuthorizationRequestParseError: Error {
    case decodingFailed
    case urlCreationFailed
    case queryItemsRetrievalFailed
    case invalidParameters
    case someParametersAreEmpty
}
