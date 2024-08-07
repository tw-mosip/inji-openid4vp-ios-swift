enum NetworkRequestException: Error {
    case invalidResponse
    case requestFailed(Error)
    case networkRequestTimeout
}
