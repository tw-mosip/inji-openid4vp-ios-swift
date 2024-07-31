import Foundation

extension Dictionary where Key == String, Value == String {
    func values(forKeys keys: [String]) -> [String]? {
        let values = keys.compactMap { self[$0] }
        return values.count == keys.count ? values : nil
    }
}

struct AuthorizationRequest {
    public let clientId: String
    public let presentation_definition: String?
    public let scope: String?
    public let response_type: String
    public let response_mode: String
    public let nonce: String
    public let state: String
    public let response_uri: String
    
    static func getAuthorizationRequest(encodedAuthorizationRequest: String, openId4VpInstance: OpenId4VP) throws {
        guard let decodedRequest = decodeAuthorizationRequest(encodedAuthorizationRequest) else {
            throw AuthorizationRequestParseError.decodingFailed
        }
        
        try parseAuthorizationRequest(decodedAuthorizationRequest: decodedRequest,openId4VpInstance: openId4VpInstance)
        
    }
    
    static func parseAuthorizationRequest(decodedAuthorizationRequest: String, openId4VpInstance: OpenId4VP) throws {
        
        guard let encodedRequestUrl = urlEncodedRequest(decodedAuthorizationRequest) else {
            throw AuthorizationRequestParseError.urlCreationFailed
        }
        
        guard let queryItems = getQueryItems(encodedRequestUrl) else {
            throw AuthorizationRequestParseError.queryItemsRetrievalFailed
        }
        
        var extractedValues: [String: String] = [:]
        for key in PresentationDefinitionParams.allKeys {
            if let queryItem = queryItems.first(where: { $0.name == key }) {
                guard let value = queryItem.value, !value.isEmpty else {
                    throw AuthorizationRequestParseError.someParametersAreEmpty
                }
                extractedValues[key] = value
            }
        }
        
        guard let clientId = extractedValues[PresentationDefinitionParams.clientid],
              let responseType = extractedValues[PresentationDefinitionParams.responsetype],
              let responseMode = extractedValues[PresentationDefinitionParams.responseMode],
              let nonce = extractedValues[PresentationDefinitionParams.nonce],
              let state = extractedValues[PresentationDefinitionParams.state],
              let responseUri = extractedValues[PresentationDefinitionParams.responseUri] else {
            throw AuthorizationRequestParseError.someParametersAreEmpty
        }
        
        let presentationDefinition = extractedValues[PresentationDefinitionParams.presentationdefinition]
        let scope = extractedValues[PresentationDefinitionParams.scope]
        
        if (presentationDefinition == nil && scope == nil || presentationDefinition != nil && scope != nil) {
            throw AuthorizationRequestParseError.invalidParameters
        }
        
        openId4VpInstance.authorizationRequest = AuthorizationRequest(
                clientId: clientId,
                presentation_definition: presentationDefinition,
                scope: scope,
                response_type: responseType,
                response_mode: responseMode,
                nonce: nonce,
                state: state,
                response_uri: responseUri
            )
        
    }
}
