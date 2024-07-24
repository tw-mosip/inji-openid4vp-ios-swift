import Foundation

public class OpenId4VP {
    let traceabilityId: String
    var authorizationRequest: AuthorizationRequest?
    
    public init(traceabilityId: String) {
        self.traceabilityId = traceabilityId
    }
    
    public func authenticateVerifier(encodedAuthenticationRequest: String, trustedVerifierJSON: String) throws -> [String: Any] {
        
        var result: [String: Any] = [:]
        
        guard let authorizationRequest = try parseAuthorizationRequest(encodedAuthorizationRequest: encodedAuthenticationRequest) else {
            throw AuthorizationRequestErrors.invalidAuthorizationRequest
        }
        self.authorizationRequest = authorizationRequest
        
        guard let decodedVerifierList = try parseTrustedVerifiers(trustedVerifierJSON: trustedVerifierJSON) else {
            throw AuthorizationRequestErrors.invalidVerifierList
        }
        
        guard let verifiedClient = try verifyClientId(verifierList: decodedVerifierList, clientId: authorizationRequest.clientId) else {
            throw AuthorizationRequestErrors.clientVerificationFailed
        }
        
        result[PresentationDefinitionParams.clientid] = verifiedClient.clientId
        
        let validationResult = try validatePresentationDefinition(presentatioDefinition: authorizationRequest.presentation_definition)
        
        if let errors = validationResult, errors.isEmpty {
            result[PresentationDefinitionParams.presentationdefinition] = authorizationRequest.presentation_definition
        } else {
            result[PresentationDefinitionError.PresentationDefinitionErrors] = validationResult
        }
        
        return result
    }
    
}
