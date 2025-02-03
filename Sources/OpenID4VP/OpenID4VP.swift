import Foundation

public class OpenID4VP {
    public let traceabilityId: String
    let networkManager: NetworkManaging
    var authorizationRequest: AuthorizationRequest?
    private var responseUri: String?
    private var credentialsMap: [String: Array<[String: Array<Any>]>]?

    public init(traceabilityId: String, networkManager: NetworkManaging? = nil) {
        self.traceabilityId = traceabilityId
        self.networkManager = networkManager ?? NetworkManager.shared
    }

    public func updateAuthorizationRequest(_ presentationDefinition: PresentationDefinition, _ clientMetadata: ClientMetadata?) {
        self.authorizationRequest?.presentationDefinition = presentationDefinition as PresentationDefinition
       
        if let clientMetadata = clientMetadata {
            self.authorizationRequest?.clientMetadata = clientMetadata
        }
    }

    public func setResponseUri(_ responseUri: String) {
        self.responseUri = responseUri
    }

    public func authenticateVerifier(encodedAuthorizationRequest: String, trustedVerifierJSON: [Verifier], shouldValidateClient: Bool = false) async throws -> AuthorizationRequest {

        Logger.setTraceabilityId(className:String(describing: type(of: self)), traceabilityId: traceabilityId)

        do {
            authorizationRequest =  try await AuthorizationRequest.validateAndGetAuthorizationRequest(encodedAuthorizationRequest: encodedAuthorizationRequest, setResponseUri: setResponseUri, networkManager: networkManager as NetworkManaging)
            
            try AuthenticationResponse.validateAuthorizationRequestPartially(authorizationRequest!, trustedVerifierJSON, updateAuthorizationRequest: updateAuthorizationRequest, shouldValidateClient: shouldValidateClient)
            
            return authorizationRequest!

        } catch(let exception) {
            await sendErrorToVerifier(error: exception)
            throw exception
        }
    }

    /**
                creates the data which requires some input from consumer for eg - signing, this will be used by consumer for perforing the required tasks
     */
    public func constructVerifiablePresentationToken(credentialsMap: [String: Array<[String: Array<Any>]>]) async throws ->  String? {
        self.credentialsMap = credentialsMap
        return try AuthorizationResponse.constructVpForSigning(credentialsMap)
    }

    /**
            Creates authorization response based on response_type and sends the authorization response to the verifier based on the response_mode
     params:  vpResponseMetadata -> dictionary of format type to vpResponseMetadata (vpResponseMetadata = input required for creation of vp_token in authorization response)
     */
    public func shareVerifiablePresentation(vpResponseMetadata: [String: VpResponseMetadata1]) async throws -> String? {
        
        do {
            //TODO: refactor to vpResponseMetadta holding formatType instead of String
            var formattedVPResponseMetadata: [FormatType: VpResponseMetadata1] = [:]
            
            for (key, value) in vpResponseMetadata {
                if let enumKey = FormatType(rawValue: key) {
                    formattedVPResponseMetadata[enumKey] = value
                }
            }
            
            
            let authorizationResponseHandler: AuthorizationResponseHandler = AuthorizationResponseHandler()
            
            let authorizationResponse = try authorizationResponseHandler.createAuthorizationReponse(authorizationRequest: self.authorizationRequest!, vpResponseMetadata: formattedVPResponseMetadata, credentialsMap: self.credentialsMap!)
            return try await authorizationResponseHandler.sendAuthorizationResponseToVerifier(authorizationResponse: authorizationResponse, authorizationRequest: self.authorizationRequest!)
            
            //            return try await AuthorizationResponse.shareVp(vpResponseMetadata: vpResponseMetadata,nonce: authorizationRequest!.nonce, state: authorizationRequest!.state, responseUri: authorizationRequest!.responseUri,presentationDefinitionId: (authorizationRequest?.presentationDefinition as! PresentationDefinition).id, networkManager: networkManager)
        } catch(let exception) {
            await sendErrorToVerifier(error: exception)
            throw exception
        }
    }

    public func sendErrorToVerifier(error: Error) async {
        guard let url = URL(string: responseUri!) else { return }
        let logTag = Logger.getLogTag(String(describing: OpenID4VP.self))
        
        let errorInfo = """
        {
            "error": \(error),
            "traceabilityId": \(traceabilityId)
        }
        """

        do {
            let response =  try await networkManager.sendHTTPRequest(url: url, method: HTTP_METHOD.POST, bodyParams: errorInfo, headers: ["Content_Type" : "application/x-www-form-urlencoded"])
            print("\(String(describing: response))")
        } catch {
            Logger.error(logTag, NetworkRequestException.invalidResponse(message: "Unexpected error occurred while sending the error to verifier: \(error)"))
        }
    }
}
