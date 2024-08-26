import Foundation

public struct AuthenticationResponse {
    let response: [String: String]
    
    static func getAuthenticationResponse(_ authorizationRequest: AuthorizationRequest,_ trustedVerifierJSON: [[Verifier]], openId4VpInstance: OpenId4VP) throws -> AuthenticationResponse {
        
        Logger.getLogTag(className: String(describing: self))
        
        var responseDict: [String: String] = [:]
        
        try verifyClientId(verifierList: trustedVerifierJSON, clientId: authorizationRequest.clientId)
        
        if (authorizationRequest.presentation_definition != nil) {
            let presentationDefinition = try PresentationDefinitionValidator.validate(presentatioDefinition:  authorizationRequest.presentation_definition!)
            
            responseDict["presentation_definition"] = authorizationRequest.presentation_definition
            
            openId4VpInstance.presentationDefinitionId = presentationDefinition.id
            
        } else if authorizationRequest.scope != nil {
            responseDict["scope"] = authorizationRequest.scope
        }
        return AuthenticationResponse(response: responseDict)
    }
    
    private static func verifyClientId(verifierList: [[Verifier]], clientId: String) throws {
        
        for verifiers in verifierList {
            for verifier in verifiers {
                if verifier.clientId == clientId {
                    guard !verifier.redirectUri.isEmpty else {
                        Logger.error("Redirect uri in verifier :\(verifier) is empty")
                        throw VerifierVerificationException.redirectUriIsEmpty
                    }
                    return
                }
            }
        }
        Logger.error("Client id not found in \(verifierList)")
        throw VerifierVerificationException.clientIdNotFound(message: "VP sharing failed: Verifier authentication was unsuccessful")
    }
}
