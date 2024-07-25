import Foundation

public class OpenId4VP {
    let traceabilityId: String
    
    public init(traceabilityId: String) {
        self.traceabilityId = traceabilityId
    }
    
    public func authenticateVerifier(encodedAuthenticationRequest: String, trustedVerifierJSON: [[Verifier]]) throws -> [String : Any] {
        
        return try AuthenticationRequestHandler.getResponse(encodedAuthenticationRequest, trustedVerifierJSON)
    }
    
}
