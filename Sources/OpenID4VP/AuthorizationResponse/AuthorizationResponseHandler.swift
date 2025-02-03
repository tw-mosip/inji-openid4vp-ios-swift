import Foundation

// constrcutProof
protocol VpTokenBuilder {
    func build() throws -> CredentialFormatSpecificVPToken
}

class LdpVpTokenBuilder : VpTokenBuilder {
    private(set) var ldpVPResponseMetadata:  LdpVPResponseMetadata
    private(set) var ldpVPTokenForSigning:  LdpVpSpecificSigningData
    private(set) var nonce: String
    
    init(ldpVPResponseMetadata:  LdpVPResponseMetadata,ldpVPTokenForSigning:  LdpVpSpecificSigningData, nonce: String) {
        self.ldpVPResponseMetadata = ldpVPResponseMetadata
        self.ldpVPTokenForSigning = ldpVPTokenForSigning
        self.nonce = nonce
    }
    
    func build() throws -> CredentialFormatSpecificVPToken {
        do{
            //TODO: Can it be moved to setter logic?
            try ldpVPResponseMetadata.validate()
            let proof = Proof.constructProof(from: ldpVPResponseMetadata, challenge: self.nonce)
            return LdpVpToken(
                context: ldpVPTokenForSigning.context,
                type: ldpVPTokenForSigning.type,
                verifiableCredential: ldpVPTokenForSigning.verifiableCredential,
                id: ldpVPTokenForSigning.id,
                holder: ldpVPTokenForSigning.holder,
                proof: proof
            )
        }
        catch {
            Logger.handleException(exceptionType: AuthorizationResponseException.unknown.errorDescription!,message: "Error occured while building vp_token for ldp_vp with error - \(error)", className: "LdpVpTokenBuilder")
            throw error
        }
    }
}

//2 vcs -> mdoc, ldpvc -> 2 VP -> [vp_ldp_vp, mdoc_vp]
//2 vcs -> ldp_vcs -> 1 VP -> vp_ldp_vp
/**
 vp_token: "{.....all fields - context}"
 */
enum VPTokenType{
    case vpTokenArray([CredentialFormatSpecificVPToken])
    case vpToken(CredentialFormatSpecificVPToken)
    
    enum CodingKeys: String, CodingKey {
        case type
        case value
    }
    
    
}

extension VPTokenType {
    var encoded: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
  
        switch self {
        case .vpTokenArray(let tokens):
            return try? encoder.encode(tokens.map{
                try encoder.encode($0)
            }) // Encodes the array directly
            
        case .vpToken(let token):
            return try? encoder.encode(token) // Encodes the single token
        }
    }
}



class VPTokenFactory {
    private let vpResponseMetadata:  VpResponseMetadata1
    private let vpTokenForSigning:  CredentialFormatSpecificSigningData
    private let nonce: String
    
    init(vpResponseMetadata:  VpResponseMetadata1,vpTokenForSigning:  CredentialFormatSpecificSigningData, nonce: String) {
        self.vpResponseMetadata = vpResponseMetadata
        self.vpTokenForSigning = vpTokenForSigning
        self.nonce = nonce
    }
    func getVPTokenBuilder(credentialFormat: FormatType) throws -> VpTokenBuilder {
        if(credentialFormat == .ldp_vc){
            return LdpVpTokenBuilder(ldpVPResponseMetadata: self.vpResponseMetadata as! LdpVPResponseMetadata, ldpVPTokenForSigning: self.vpTokenForSigning as! LdpVpSpecificSigningData, nonce: nonce)
        } else {
            throw AuthorizationResponseException.unsupportedFormatOfLibrary
        }
    }
    
    func getClass(credentialFormat: FormatType) throws -> CredentialFormatSpecificVPToken.Type {
        if(credentialFormat == .ldp_vc){
            return LdpVpToken.self
        } else {
            throw AuthorizationResponseException.unsupportedFormatOfLibrary
        }
    }
}

public struct AuthorizationResponse1 {
    let vpToken: VPTokenType
    let presentation_submission: PresentationSubmission
    
    init(vpToken: VPTokenType, presentation_submission: PresentationSubmission) {
        self.vpToken = vpToken
        self.presentation_submission = presentation_submission
    }
    
    func encodedItems() throws -> [(name: String, value: String)] {
        //TODO: This has so much of Hard coding Can it be removed?
        let encodedVPTokenData: String, encodedPresentationSubmissionData: String
        do {
            encodedVPTokenData = try String(data: vpToken.encoded!, encoding: .utf8) ?? ""
        } catch let error {
            throw Logger.handleException(exceptionType: "JsonEncodingFailed", message: error.localizedDescription, fieldPath: ["vp_token"], className: AuthorizationResponse.className)
        }
        
        do {
            encodedPresentationSubmissionData = try encodeToJsonString(self.presentation_submission)!
        } catch let error {
            throw Logger.handleException(exceptionType: "JsonEncodingFailed", message: error.localizedDescription, fieldPath: ["presentation_submission"], className: AuthorizationResponse.className)
        }
        
        var encodedItems : [(name: String, value: String)] = []
        encodedItems.append((name: "vp_token",value: encodedVPTokenData))
        encodedItems.append((name: "presentation_definition",value: encodedPresentationSubmissionData))
        return encodedItems
    }
}




public class AuthorizationResponseHandler {
    var vpToken: VPTokenType?
    var presentation_definition: PresentationDefinition?
    static var selectedCredentials: [String: Array<[String: Array<Any>]>] = [:]
    static var vpTokensForSigning: [FormatType: CredentialFormatSpecificSigningData] = [:]
    var path: [FormatType: (index: Int, nestedIndex: Int)] = [:]
    //TODO: Hold authorization request
    
    func createVPToken(vpTokenForSigning signedPayloads: [FormatType: VpResponseMetadata1]) throws -> VPTokenType {
        var vpTokenOfCredentials: [CredentialFormatSpecificVPToken] = []
        
        for(credentialFormat, vpResponseMetata) in signedPayloads{
            do {
                //TODO: Get nonce from AuthRequest
                let vpTokenBuilder = try VPTokenFactory(vpResponseMetadata: vpResponseMetata, vpTokenForSigning: (AuthorizationResponse.vpTokenForSigning?[credentialFormat]!)!, nonce: "String").getVPTokenBuilder(credentialFormat: credentialFormat)
                let credentialSpecificVPToken = try vpTokenBuilder.build()
                //                let credentialSpecificVPToken = VPTokenFactory.getClass(credentialFormat: credentialFormat).create(ldpVPResponseMetadata:  vpResponseMetata,ldpVPTokenForSigning:  AuthorizationResponseHandler.vpTokensForSigning[credentialFormat]!, nonce: "String")
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
    
    func createInputDescriptor(credentialsMap: [String: Array<[String: Array<Any>]>]) throws -> [DescriptorMap] {
        var descriptorsMap: [DescriptorMap] = []
        var formatTypeMap : [String: FormatType] = ["ldp_vc": .ldp_vc]
        
        //Assumption based on multiple vps, presentation_submission to be changed to replace $[0] to $ based if single VP
        //Format -> PathIndex, same ordering needs to be followed during VPToken creation
        for(inputDescriptorId, matchingVcs) in credentialsMap {
            do {
                try matchingVcs.forEach { matchingVcsGroupedByCredentialFormat in
                    
                    for(format, matchingVcOfFormat) in matchingVcsGroupedByCredentialFormat {
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
    
    private func createPresentationSubmission(credentialsMap: [String: Array<[String: Array<Any>]>], authorizationRequest: AuthorizationRequest) throws -> PresentationSubmission {
        let descriptorMap = try createInputDescriptor(credentialsMap: credentialsMap)
        let presentationDefinitionId = (authorizationRequest.presentationDefinition as! PresentationDefinition).id
        
        return PresentationSubmission(definition_id: presentationDefinitionId, descriptor_map: descriptorMap)
    }
    
    //TODO: This will be exposed method for creation of auth response
    func createAuthorizationReponse(authorizationRequest: AuthorizationRequest, vpResponseMetadata inputRequiredForAuthorizationResponseCreation: [FormatType: VpResponseMetadata1], credentialsMap: [String: Array<[String: Array<Any>]>]) throws -> AuthorizationResponse1 {
        do {
            print("authorizationRequest \(authorizationRequest)|||")
            if(authorizationRequest.responseType == ResponseType.vp_token.rawValue){
                let vpToken = try createVPToken(vpTokenForSigning: inputRequiredForAuthorizationResponseCreation)
                let presentationSubmission = try createPresentationSubmission(credentialsMap: credentialsMap, authorizationRequest: authorizationRequest)
                
                return AuthorizationResponse1(vpToken: vpToken, presentation_submission: presentationSubmission)
            }
            throw AuthorizationResponseException.unsupportedResponseType
        }
        catch {
            throw error
        }
    }
    
    //TODO: This will be exposed method for sending the response to verifier
    func sendAuthorizationResponseToVerifier(authorizationResponse: AuthorizationResponse1, authorizationRequest: AuthorizationRequest) async throws -> String?  {
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
                guard let url = URL(string: authorizationRequest.responseUri) else {
                    throw Logger.handleException(exceptionType: "UrlCreationFailed", fieldPath: ["response_uri"], className: AuthorizationResponse.className)
                }
                
                //5. make api call
                return try await NetworkManager.shared.sendHTTPRequest(url: url, method: HTTP_METHOD.POST, bodyParams: requestBody ?? "", headers: ["Content-Type" : "application/x-www-form-urlencoded"])
            }
            catch {
                print("error os Unable to send authorization response to the provided response_uri via direct_post with error \(error)")
                throw Logger.handleException(exceptionType: "AuthorizationResponseSendingFailed",message: "Unable to send authorization response to the provided response_uri via direct_post with error \(error)", className: AuthorizationResponse.className)
            }
        default:
            throw AuthorizationResponseException.unsupportedResponseMode
        }
    }
}

