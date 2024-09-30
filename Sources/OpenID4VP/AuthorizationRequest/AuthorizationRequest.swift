import Foundation

extension Dictionary where Key == String, Value == String {
    func values(forKeys keys: [String]) -> [String]? {
        let values = keys.compactMap { self[$0] }
        return values.count == keys.count ? values : nil
    }
}

public struct AuthorizationRequest {
    let clientId: String
    let presentationDefinition: String?
    let responseType: String
    let responseMode: String
    let nonce: String
    let state: String
    let responseUri: String
    
    static func getAuthorizationRequest(encodedAuthorizationRequest: String, setResponseUri: (String) -> Void) throws -> AuthorizationRequest {
        
        Logger.getLogTag(className: String(describing: self))
        
        let requestParts = encodedAuthorizationRequest.components(separatedBy: "?")
           guard requestParts.count > 1 else {
               Logger.error("Invalid AuthorizationRequest format. No query string found.")
               throw AuthorizationRequestException.decodingException
           }
           
        let baseUrl = requestParts[0]
        let encodedQuery = requestParts[1]
        
        guard let decodedQuery = decodeAuthorizationRequest(encodedQuery) else {
            Logger.error("Decoding of the AuthorizationRequest failed.")
            throw AuthorizationRequestException.decodingException
        }
        
        let decodedRequest = "\(baseUrl)?\(decodedQuery)"
        
        return try parseAuthorizationRequest(decodedAuthorizationRequest: decodedRequest, setResponseUri: setResponseUri)
        
    }
    
    private static func parseAuthorizationRequest(decodedAuthorizationRequest: String, setResponseUri: (String) -> Void) throws -> AuthorizationRequest {
        
        guard let encodedRequestUrl = urlEncodedRequest(decodedAuthorizationRequest) else {
            Logger.error("URLEncoding of the AuthorizationRequest failed while parsing.")
            throw AuthorizationRequestException.urlCreationFailed
        }
        
        guard let queryItems = getQueryItems(encodedRequestUrl) else {
            Logger.error("Query items retrieval from AuthorizationRequest failed.")
            throw AuthorizationRequestException.queryItemsRetrievalFailed
        }
        
        let params = try extractQueryParams(from: queryItems)
        
        try validateQueryParams(params,setResponseUri)
        
        return AuthorizationRequest(
            clientId: params["client_id"]!,
            presentationDefinition: params["presentation_definition"],
            responseType: params["response_type"]!,
            responseMode: params["response_mode"]!,
            nonce: params["nonce"]!,
            state: params["state"]!,
            responseUri: params["response_uri"]!
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
    
    
    private static func validateQueryParams(_ values: [String: String], _ setResponseUri: (String) -> Void) throws {
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
        
        if (presentationDefinition != nil) {
            requiredKeys.append("presentation_definition")
        } else {
            errorMessage = "presentation_definition request param must be present."
            Logger.error(errorMessage)
            throw AuthorizationRequestException.invalidQueryParams(message: errorMessage)
        }
        
        for key in requiredKeys {
            if values[key] == nil  {
                Logger.error("AuthorizationRequest parameter \(key) should not be null.")
                throw AuthorizationRequestException.missingInput(fieldName: key)
            }
            if key == "response_uri" {
                setResponseUri(values["response_uri"]!)
            }
            if values[key] == "" || values[key] == "null" {
                Logger.error("AuthorizationRequest parameter \(key) should not be null.")
                throw AuthorizationRequestException.invalidInput(fieldName: key)
            }
        }
    }
}
