import Foundation

extension Dictionary where Key == String, Value == String {
    func values(forKeys keys: [String]) -> [String]? {
        let values = keys.compactMap { self[$0] }
        return values.count == keys.count ? values : nil
    }
}

struct AuthorizationRequest {
    let clientId: String
    let presentation_definition: String?
    let scope: String?
    let response_type: String
    let response_mode: String
    let nonce: String
    let state: String
    let response_uri: String
    
    static func getAuthorizationRequest(encodedAuthorizationRequest: String, openId4VpInstance: OpenId4VP) throws {
        
        Logger.getLogTag(className: String(describing: self))
        
        guard let decodedRequest = decodeAuthorizationRequest(encodedAuthorizationRequest) else {
            Logger.error("Decoding of the AuthorizationRequest failed.")
            throw AuthorizationRequestException.decodingException
        }
        
        try parseAuthorizationRequest(decodedAuthorizationRequest: decodedRequest,openId4VpInstance: openId4VpInstance)
        
    }
    
    private static func parseAuthorizationRequest(decodedAuthorizationRequest: String, openId4VpInstance: OpenId4VP) throws {
        
        guard let encodedRequestUrl = urlEncodedRequest(decodedAuthorizationRequest) else {
            Logger.error("URLEncoding of the AuthorizationRequest failed while parsing.")
            throw AuthorizationRequestException.urlCreationFailed
        }
        
        guard let queryItems = getQueryItems(encodedRequestUrl) else {
            Logger.error("Query items retrieval from AuthorizationRequest failed.")
            throw AuthorizationRequestException.queryItemsRetrievalFailed
        }
        
        let params = try extractQueryParams(from: queryItems)
        
        try validateQueryParams(params,openId4VpInstance)
        
        openId4VpInstance.authorizationRequest = AuthorizationRequest(
            clientId: params["client_id"]!,
            presentation_definition: params["presentation_definition"],
            scope: params["scope"],
            response_type: params["response_type"]!,
            response_mode: params["response_mode"]!,
            nonce: params["nonce"]!,
            state: params["state"]!,
            response_uri: params["response_uri"]!
        )
        
    }
    
    private static func extractQueryParams(from queryItems: [URLQueryItem]) throws -> [String: String] {
        var extractedValues: [String: String] = [:]
        
        for queryItem in queryItems {
            guard let value = queryItem.value, !value.isEmpty else {
                Logger.error("Query parameter value should not be empty: \(queryItem)")
                throw AuthorizationRequestException.parameterValuesAreEmpty
            }
            extractedValues[queryItem.name] = value
        }
        
        return extractedValues
    }
    
    
    private static func validateQueryParams(_ values: [String: String],_ openId4VpInstance: OpenId4VP) throws {
        var requiredKeys = [
            "client_id",
            "response_type",
            "response_mode",
            "nonce",
            "state",
            "response_uri"
        ]
        
        var errorMessage: String
        
        let presentationDefinition = values["presentation_definition"]
        let scope = values["scope"]
        
        if (presentationDefinition != nil && scope != nil) {
            errorMessage = "Only one of presentation_definition or scope request param can be present."
            Logger.error(errorMessage)
            throw AuthorizationRequestException.invalidQueryParams(message: errorMessage)
        } else if (presentationDefinition != nil) {
            requiredKeys.append("presentation_definition")
        } else if (scope != nil) {
            requiredKeys.append("scope")
        } else {
            errorMessage = "Either presentation_definition or scope request param must be present."
            Logger.error(errorMessage)
            throw AuthorizationRequestException.invalidQueryParams(message: errorMessage)
        }
        
        for key in requiredKeys {
            if values[key] == nil  {
                Logger.error("AuthorizationRequest parameter \(key) should not be null.")
                throw AuthorizationRequestException.missingInput(fieldName: key)
            }
            if key == "response_uri" {
                openId4VpInstance.responseUri = values["response_uri"]
            }
            if values[key] == "" || values[key] == "null" {
                Logger.error("AuthorizationRequest parameter \(key) should not be null.")
                throw AuthorizationRequestException.invalidInput(fieldName: key)
            }
        }
    }
}
