import Foundation

extension Dictionary where Key == String, Value == String {
    func values(forKeys keys: [String]) -> [String]? {
        let values = keys.compactMap { self[$0] }
        return values.count == keys.count ? values : nil
    }
}

func decodeAuthorizationRequest(_ encodedAuthorizationRequest: String) -> String? {
    return Data(base64Encoded: encodedAuthorizationRequest)
        .flatMap { String(data: $0, encoding: .utf8) }
}

func urlEncodedRequest(_ decodedRequest: String) -> URL? {
    return decodedRequest.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        .flatMap { URL(string: $0) }
}

func getQueryItems(_ encodedUrl: URL) -> [URLQueryItem]? {
    return URLComponents(url: encodedUrl, resolvingAgainstBaseURL: false)?.queryItems
}


public func verifyClientId(verifierList: [[Verifier]], clientId: String) throws -> Verifier? {
    guard let decodedClientId = clientId.removingPercentEncoding else {
        throw VerifierVerificationError.invalidClientId
    }
    
    for (index,verifier) in verifierList.enumerated() {
        if verifier[index].clientId == decodedClientId {
            return Verifier(clientId: verifier[index].clientId, redirectUri: verifier[index].redirectUri)
        } else {
            throw VerifierVerificationError.missingRedirectUri
        }
    }
    throw VerifierVerificationError.clientIdNotFound
}


