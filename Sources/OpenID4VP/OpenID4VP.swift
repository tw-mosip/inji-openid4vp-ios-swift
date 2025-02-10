import Foundation


public class OpenID4VP {
    public let traceabilityId: String
    let networkManager: NetworkManaging
    var authorizationRequest: AuthorizationRequest?
    private var authorizationResponseHandler: AuthorizationResponseHandler?
    private var responseUri: String?
    private var credentialsMap: [String: [String: Array<Any>]]?
    private var vpTokensForSigning: [FormatType: CredentialFormatSpecificSigningData] = [:]

    public init(traceabilityId: String, networkManager: NetworkManaging? = nil) {
        self.traceabilityId = traceabilityId
        self.networkManager = networkManager ?? NetworkManager.shared
        self.authorizationResponseHandler = AuthorizationResponseHandler(networkManager: networkManager)
        print("auth handler set up successfully with network manager")
    }

    public func setResponseUri(_ responseUri: String) {
        self.responseUri = responseUri
    }

    public func authenticateVerifier(encodedAuthorizationRequest: String, trustedVerifierJSON: [Verifier], shouldValidateClient: Bool = false) async throws -> AuthorizationRequest {

        Logger.setTraceabilityId(className:String(describing: type(of: self)), traceabilityId: traceabilityId)

        do {
            authorizationRequest =  try await AuthorizationRequest.validateAndGetAuthorizationRequest(encodedAuthorizationRequest: encodedAuthorizationRequest,setResponseUri: setResponseUri, shouldValidateClient: shouldValidateClient, trustedVerifierJSON: trustedVerifierJSON, networkManager: networkManager as NetworkManaging)
            
            return authorizationRequest!

        } catch(let exception) {
            await sendErrorToVerifier(error: exception)
            throw exception
        }
    }

    /// Creates the data which requires some input from consumer here it is - signing, this will be used by consumer for performing the required tasks
    public func constructVerifiablePresentationToken(credentialsMap: [String: [String: Array<Any>]]) async throws ->  [String: String] {
        self.credentialsMap = credentialsMap
        self.vpTokensForSigning =  try authorizationResponseHandler!.constructDataForSigning(credentialsMap: credentialsMap)
        let encodedResult = try encodeVPTokenForSigning(self.vpTokensForSigning)
        return encodedResult
    }

    /// Creates authorization response based on response_type and sends the authorization response to the verifier based on the response_mode params:  vpResponseMetadata -> dictionary of format type to vpResponseMetadata (vpResponseMetadata = input required for creation of vp_token in authorization response)
    public func shareVerifiablePresentation(vpResponseMetadata: [String: VpResponseMetadata]) async throws -> String? {
        
        do {
            var formattedVPResponseMetadata: [FormatType: VpResponseMetadata] = [:]
            
            for (key, value) in vpResponseMetadata {
                if let enumKey = FormatType(rawValue: key) {
                    formattedVPResponseMetadata[enumKey] = value
                }
            }
            print("authorizationResponseHandler \(String(describing: self.authorizationResponseHandler.debugDescription))")
            print("auth request \(String(describing: self.authorizationRequest))")
            let authorizationResponse = try self.authorizationResponseHandler!.createAuthorizationReponse(authorizationRequest: self.authorizationRequest!, vpResponseMetadata: formattedVPResponseMetadata, vpTokensForSigning: self.vpTokensForSigning, credentialsMap: self.credentialsMap!)
            return try await self.authorizationResponseHandler!.sendAuthorizationResponseToVerifier(authorizationResponse: authorizationResponse, authorizationRequest: self.authorizationRequest!)
        } catch(let exception) {
            await sendErrorToVerifier(error: exception)
            throw exception
        }
    }

    public func sendErrorToVerifier(error: Error) async {
        guard let url = URL(string: responseUri ?? "") else { return }
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
