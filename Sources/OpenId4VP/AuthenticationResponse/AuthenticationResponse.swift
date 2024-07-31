import Foundation

public class AuthenticationResponse {
    let response: [String: String]
    
    init(response: [String: String]) {
        self.response = response
    }
    
    static func getAuthenticationResponse(_ authorizationRequest: AuthorizationRequest,_ trustedVerifierJSON: [[Verifier]], openId4VpInstance: OpenId4VP) throws -> AuthenticationResponse{
        
        try verifyClientId(verifierList: trustedVerifierJSON, clientId: authorizationRequest.clientId)
        
        var responseDict: [String: String] = [:]
        
        if (authorizationRequest.presentation_definition != nil) {
            let presentationDefinition = try PresentationDefinitionValidator.validate(presentatioDefinition:  authorizationRequest.presentation_definition!)
            
            responseDict[PresentationDefinitionParams.presentationdefinition] = authorizationRequest.presentation_definition
            
            openId4VpInstance.presentationDefinitionId = presentationDefinition.id
            
        } else if let scope = authorizationRequest.scope {
            responseDict[PresentationDefinitionParams.scope] = authorizationRequest.scope
        }
        return AuthenticationResponse(response: responseDict)
    }
    
    static func verifyClientId(verifierList: [[Verifier]], clientId: String) throws {
        guard let decodedClientId = clientId.removingPercentEncoding else {
            throw VerifierVerificationError.invalidClientId
        }
        
        for verifiers in verifierList {
            for verifier in verifiers {
                if verifier.clientId == decodedClientId {
                    guard !verifier.redirectUri.isEmpty else {
                        throw VerifierVerificationError.missingRedirectUri
                    }
                    return
                }
            }
        }
        throw VerifierVerificationError.clientIdNotFound
    }
}
