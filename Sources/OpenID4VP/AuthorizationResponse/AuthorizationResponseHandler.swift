import Foundation

public class AuthorizationResponseHandler {
    let networkManager: NetworkManaging
    var vpToken: VPTokenType?
    private var vpTokensForSigning: [FormatType: CredentialFormatSpecificSigningData] = [:]
    private    var path: [FormatType: (index: Int, nestedIndex: Int)] = [:]
    private    var authorizationRequest: AuthorizationRequest?
    
    public init(networkManager: NetworkManaging? = nil) {
        self.networkManager = networkManager ?? NetworkManager.shared
    }
    
    func createAuthorizationReponse(authorizationRequest: AuthorizationRequest, vpResponseMetadata signingDataForAuthorizationResponseCreation: [FormatType: VpResponseMetadata],vpTokensForSigning: [FormatType: CredentialFormatSpecificSigningData], credentialsMap: [String: Array<[String: Array<Any>]>]) throws -> AuthorizationResponse {
        do {
            self.authorizationRequest = authorizationRequest
            self.vpTokensForSigning = vpTokensForSigning
            if(authorizationRequest.responseType == ResponseType.vp_token.rawValue){
                let vpToken = try createVPToken(vpTokenForSigning: signingDataForAuthorizationResponseCreation)
                let presentationSubmission = try createPresentationSubmission(credentialsMap: credentialsMap, authorizationRequest: authorizationRequest)
                
                return AuthorizationResponse(vpToken: vpToken, presentation_submission: presentationSubmission)
            }
            throw AuthorizationResponseException.unsupportedResponseType
        }
        catch {
            throw error
        }
    }
    
    public func sendAuthorizationResponseToVerifier(authorizationResponse: AuthorizationResponse, authorizationRequest: AuthorizationRequest) async throws -> String?  {
        switch authorizationRequest.responseMode {
        case ResponseMode.direct_post.rawValue:
            do {
                //1. get encoded body item authorization response
                let authorizationResponseEncodedItems : [URLQueryItem] = try authorizationResponse.encodedItems().map{ URLQueryItem(name: $0.name, value: encodeQueryValue($0.value))}
                
                //2. gather request body items
                var bodyComponents = [URLQueryItem]()
                bodyComponents.append(contentsOf: authorizationResponseEncodedItems)
                bodyComponents.append(URLQueryItem(name: "state", value: encodeQueryValue(authorizationRequest.state)))
                
                //3. construct request body
                var urlComponents = URLComponents()
                urlComponents.queryItems = bodyComponents
                let requestBody = urlComponents.query
                
                //4. construct url
                guard let url = URL(string: authorizationRequest.responseUri!) else {
                    throw Logger.handleException(exceptionType: "UrlCreationFailed", fieldPath: ["response_uri"], className: AuthorizationResponse.className)
                }
                
                //5. make api call
                return try await networkManager.sendHTTPRequest(url: url, method: HTTP_METHOD.POST, bodyParams: requestBody ?? "", headers: ["Content-Type" : "application/x-www-form-urlencoded"])
            }
            catch {
                print("error os Unable to send authorization response to the provided response_uri via direct_post with error \(error)")
                throw Logger.handleException(exceptionType: "AuthorizationResponseSendingFailed",message: "Unable to send authorization response to the provided response_uri via direct_post with error \(error)", className: AuthorizationResponse.className)
            }
        default:
            throw AuthorizationResponseException.unsupportedResponseMode
        }
    }
    
    func constructDataForSigning(credentialsMap: [String: Array<[String: Array<Any>]>])throws -> [FormatType: CredentialFormatSpecificSigningData] {
        self.vpTokensForSigning = try CredentialFormatSpecificSigningDataMapCreator.create(selectedCredentials: credentialsMap)
        return self.vpTokensForSigning
    }
    
    private func createVPToken(vpTokenForSigning signedPayloads: [FormatType: VpResponseMetadata]) throws -> VPTokenType {
        var vpTokenOfCredentials: [CredentialFormatSpecificVPToken] = []
        
        for(credentialFormat, vpResponseMetata) in signedPayloads{
            do {
                //TODO: Get nonce from AuthRequest
                let vpTokenBuilder = try VPTokenFactory(vpResponseMetadata: vpResponseMetata, vpTokenForSigning: (self.vpTokensForSigning[credentialFormat]!), nonce: authorizationRequest!.nonce).getVPTokenBuilder(credentialFormat: credentialFormat)
                let credentialSpecificVPToken = try vpTokenBuilder.build()
                vpTokenOfCredentials.append(credentialSpecificVPToken)
            }
            catch {
                throw error
            }
        }
        if(vpTokenOfCredentials.count == 1 ){
            self.vpToken =  VPTokenType.vpToken(vpTokenOfCredentials.first!)
        }
        else{
            // TODO: format Format -> PathIndex, same ordering needs to be followed during VPToken creation
            self.vpToken = VPTokenType.vpTokenArray(vpTokenOfCredentials)
        }
        
        return vpToken!
    }
    
    private func createPresentationSubmission(credentialsMap: [String: Array<[String: Array<Any>]>], authorizationRequest: AuthorizationRequest) throws -> PresentationSubmission {
        let descriptorMap = try createInputDescriptor(credentialsMap: credentialsMap)
        let presentationDefinitionId = authorizationRequest.clientId
        
        return PresentationSubmission(definition_id: presentationDefinitionId, descriptor_map: descriptorMap)
    }
    
    private func createInputDescriptor(credentialsMap: [String: Array<[String: Array<Any>]>]) throws -> [DescriptorMap] {
        var descriptorsMap: [DescriptorMap] = []
        let formatTypeMap : [String: FormatType] = ["ldp_vc": .ldp_vc]
        
        //Based on multiple vps, presentation_submission to be changed to replace $[0] to $ based if single VP
        //Format -> PathIndex, same ordering needs to be followed during VPToken creation
        for(inputDescriptorId, matchingVcs) in credentialsMap {
            do {
                try matchingVcs.forEach { matchingVcsGroupedByCredentialFormat in
                    for(format, _) in matchingVcsGroupedByCredentialFormat {
                        //construct format type
                        var formatType: FormatType? = formatTypeMap[format]
                        let pathIndex = path[formatType!]?.index ?? path.count
                        var nestedPathIndex = (path[formatType!]?.nestedIndex ?? 0)
                        if(format == FormatType.ldp_vc.rawValue){
                            formatType = .ldp_vc
                            descriptorsMap.append(DescriptorMap(id: inputDescriptorId, format: .ldp_vc, path: "$[\(pathIndex)]", path_nested: "$[\(pathIndex)].\(LdpVpToken.internalPath)[\(nestedPathIndex)]"))
                        }
                        guard formatType != nil else {
                            throw AuthorizationResponseException.unsupportedFormatOfLibrary
                        }
                        //increment
                        nestedPathIndex += 1
                        path[formatType!] = (index: pathIndex, nestedIndex: nestedPathIndex+1)
                    }
                    
                }
            } catch {
                throw error
            }
        }
        
        return descriptorsMap
    }
}

