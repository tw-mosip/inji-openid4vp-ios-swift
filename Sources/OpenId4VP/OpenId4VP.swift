import Foundation

public class OpenId4VP {
    let traceabilityId: String
    let networkManager: NetworkManaging
    var authorizationRequest: AuthorizationRequest?
    var presentationDefinitionId: String?
    var responseUri: String?
    
    init(traceabilityId: String, networkManager: NetworkManaging? = nil) {
        self.traceabilityId = traceabilityId
        self.networkManager = networkManager ?? NetworkManager.shared
    }
    
    public func authenticateVerifier(encodedAuthenticationRequest: String, trustedVerifierJSON: [[Verifier]]) async throws -> AuthenticationResponse {
        
        Logger.setLogTag(className:String(describing: type(of: self)), traceabilityId: traceabilityId)
        Logger.getLogTag(className: String(describing: type(of: self)))
        
        do {
            try AuthorizationRequest.getAuthorizationRequest(encodedAuthorizationRequest: encodedAuthenticationRequest, openId4VpInstance: self)
                
            return try AuthenticationResponse.getAuthenticationResponse(authorizationRequest!, trustedVerifierJSON, openId4VpInstance: self)
            
        } catch(let exception) {
           await sendErrorToResponseUri(error: exception, uri: responseUri!)
           throw exception
        }
    }
    
    public func constructVerifiablePresentation(credentialsMap: [String: [String]]) async throws ->  String? {
        do {
            return try AuthorizationResponse.constructVpForSigning(credentialsMap)
        } catch(let exception) {
            await sendErrorToResponseUri(error: exception, uri: responseUri!)
            throw exception
        }
    }
    
    public func shareVerifiablePresentation(vpResponseMetadata: VPResponseMetadata) async throws -> String? {
        
        do {
            return try await AuthorizationResponse.shareVp(vpResponseMetadata: vpResponseMetadata, openId4VpInstance: self, networkManager: networkManager)
        } catch(let exception) {
            await sendErrorToResponseUri(error: exception, uri: responseUri!)
            throw exception
        }
    }
    
    private func sendErrorToResponseUri(error: Error, uri: String) async {
        
        guard let url = URL(string: uri) else { return }
        
        let errorInfo = """
        {
            "error": \(error),
            "traceabilityId": \(traceabilityId)
        }
        """

            do {
                let response =  try await networkManager.sendHTTPPostRequest(requestBody: errorInfo, url: url)
                print("\(String(describing: response))")
            } catch {
                Logger.error("Unexpected error occurred while sending the error to verifier.")
            }
    }
}
