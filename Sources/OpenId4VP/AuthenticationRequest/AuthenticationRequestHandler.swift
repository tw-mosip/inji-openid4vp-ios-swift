import Foundation

public class AuthenticationRequestHandler{
    
    static func parseRequest(encodedAuthorizationRequest: String) throws -> AuthenticationRequest? {
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
        for key in PresentationDefinitionParams.allKeys {
            if let queryItem = queryItems.first(where: { $0.name == key }) {
                guard let value = queryItem.value, !value.isEmpty else {
                    throw AuthorizationRequestParseError.someParametersAreEmpty
                }
                extractedValues[key] = value
            }
        }
        
        return try AuthenticationRequest.constructAuthorizationRequest(requestParams: extractedValues)
    }
    
    static func getResponse(_ encodedAuthenticationRequest: String,_ trustedVerifierJSON: [[Verifier]]) throws -> [String : Any]{
        
        var result: [String: Any] = [:]
        
        let authorizationRequest = try parseRequest(encodedAuthorizationRequest: encodedAuthenticationRequest)
        
        
        let verifiedClient = try verifyClientId(verifierList: trustedVerifierJSON, clientId: authorizationRequest!.clientId)
        
        result[PresentationDefinitionParams.clientid] = verifiedClient?.clientId
        
        try PresentationDefinitionValidator.validate(presentatioDefinition: authorizationRequest!.presentation_definition)
        
        result[PresentationDefinitionParams.presentationdefinition] = authorizationRequest?.presentation_definition
        
        return result
    }
}
