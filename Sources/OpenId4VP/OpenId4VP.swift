import Foundation

public class OpenId4VP {
    let traceabilityId: String
    var authorizationRequest: AuthorizationRequest?
    var presentationDefinitionId: String?
    
    init(traceabilityId: String) {
        self.traceabilityId = traceabilityId
    }
    
    public func authenticateVerifier(encodedAuthenticationRequest: String, trustedVerifierJSON: [[Verifier]]) throws -> AuthenticationResponse {
        
        Logger.getLogTag(className: String(describing: type(of: self)), traceabilityId: traceabilityId)
        
        try AuthorizationRequest.getAuthorizationRequest(encodedAuthorizationRequest: encodedAuthenticationRequest, openId4VpInstance: self)
        
       return try AuthenticationResponse.getAuthenticationResponse(authorizationRequest!, trustedVerifierJSON, openId4VpInstance: self)
    }
    
    public func constructVerifiablePresentation(credentialsMap: [String: [String]]) throws ->  String? {

        return try AuthorizationResponse.constructVpForSigning(credentialsMap)
        
    }
    
    public func sendVp(jws: String, signatureAlgoType: String, publicKey: String, domain: String, networkManager: NetworkManaging? = nil) async throws -> HTTPURLResponse? {
        
        let networkManager = networkManager ?? NetworkManager.shared
        
        return try await AuthorizationResponse.shareVp(jws: jws,signatureAlgoType: signatureAlgoType,publicKey: publicKey,domain: domain, openId4VpInstance: self, networkManager: networkManager)
    }
}
