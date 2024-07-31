import Foundation

public class OpenId4VP {
    let traceabilityId: String
    var authorizationRequest: AuthorizationRequest?
    var presentationDefinitionId: String?
    
    public init(traceabilityId: String) {
        self.traceabilityId = traceabilityId
    }
    
    public func authenticateVerifier(encodedAuthenticationRequest: String, trustedVerifierJSON: [[Verifier]]) throws -> AuthenticationResponse? {
        
        try AuthorizationRequest.getAuthorizationRequest(encodedAuthorizationRequest: encodedAuthenticationRequest, openId4VpInstance: self)
        
       return try AuthenticationResponse.getAuthenticationResponse(authorizationRequest!, trustedVerifierJSON, openId4VpInstance: self)
    }
    
    public func constructVerifiablePresentation(credentialsMap: [String: [String]]) throws -> String {
        
        let credentialsMap: [String: [String]] = ["bank_input":["VC1","VC2"],"employment_input": ["VC3","VC4"]]
        
        presentationDefinitionId = "hii"
        
        let authorizationResponse = try AuthorizationResponse.constructResponse(presentationDefinitionId!,descriptorMap: credentialsMap)
        
        
//        print(authorizationResponse.presentationSubmission!, authorizationResponse.vpToken?.id!)
        return ""
        
    }
    
}
