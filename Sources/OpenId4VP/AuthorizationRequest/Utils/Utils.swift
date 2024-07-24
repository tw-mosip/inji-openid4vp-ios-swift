import Foundation

func decodeAuthorizationRequest(_ encodedAuthorizationRequest: String) -> String? {
    guard let data = Data(base64Encoded: encodedAuthorizationRequest) else {
        return nil
    }
    guard let message = String(data: data, encoding: .utf8) else {
        return nil
    }
    return message
}

func urlEncodedRequest(_ decodedRequest: String) -> URL? {
    guard let encodedUrlString = decodedRequest.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
        return nil
    }
    guard let encodedUrl = URL(string: encodedUrlString) else {
        return nil
    }
    return encodedUrl
}

func getQueryItems(_ encodedUrl: URL) -> [URLQueryItem]? {
    guard let urlComponents = URLComponents(url: encodedUrl, resolvingAgainstBaseURL: false) else {
        return nil
    }
    guard let queryItems = urlComponents.queryItems else {
        return nil
    }
    return queryItems
}

func parseAuthorizationRequest(encodedAuthorizationRequest: String) throws -> AuthorizationRequest? {
    guard let decodedRequest = decodeAuthorizationRequest(encodedAuthorizationRequest) else {
        throw AuthorizationRequestParseError.decodingFailed
    }
    
    guard let encodedRequestUrl = urlEncodedRequest(decodedRequest) else {
        throw AuthorizationRequestParseError.urlCreationFailed
    }
    
    guard let queryItems = getQueryItems(encodedRequestUrl) else {
        throw AuthorizationRequestParseError.queryItemsRetrievalFailed
    }

    var extractedValues: [String: String] = [:]
    for item in queryItems {
        if PresentationDefinitionParams.allKeys.contains(item.name) {
                   guard let value = item.value, !value.isEmpty else {
                       throw AuthorizationRequestParseError.someParametersAreEmpty
                   }
                   extractedValues[item.name] = value
               }
    }
    
    do {
        return try AuthorizationRequest.constructAuthorizationRequest(requestParams: extractedValues)
    } catch {
        throw AuthorizationRequestParseError.invalidParameters
    }
}

public func parseTrustedVerifiers(trustedVerifierJSON: String) throws -> [[String: Any]]? {
    
    guard let jsonData = trustedVerifierJSON.data(using: .utf8) else {
        throw AuthorizationRequestErrors.invalidVerifierList
    }
    
    do {
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
        
        guard let jsonArray = jsonObject as? [[String: Any]] else {
            throw AuthorizationRequestErrors.unexpectedFormat
        }
        return jsonArray
        
    } catch {
        throw AuthorizationRequestErrors.jsonDecodingFailed
    }
}

public func verifyClientId(verifierList: [[String: Any]], clientId: String) throws -> Verifier? {
    guard let decodedClientId = clientId.removingPercentEncoding else {
        throw VerifierVerificationError.invalidClientId
    }
    
    for verifier in verifierList {
        if let verifierClientId = verifier[PresentationDefinitionParams.clientid] as? String,
           verifierClientId == decodedClientId {
            if let redirectUri = verifier[VerifierParams.redirect_uri] as? [String] {
                return Verifier(clientId: verifierClientId, redirectUri: redirectUri)
            } else {
                throw VerifierVerificationError.missingRedirectUri
            }
        }
    }
    throw VerifierVerificationError.clientIdNotFound
}

