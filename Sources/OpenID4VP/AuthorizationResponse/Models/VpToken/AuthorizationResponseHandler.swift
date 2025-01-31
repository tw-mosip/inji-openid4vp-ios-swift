import Foundation

//VPResponseMetadata - signed payload
protocol VpResponseMetadata {
    
}

class LdpVPResponseMetadata : VpResponseMetadata {
    let jws: String
    let signatureAlgorithm: String
    let publicKey: String
    let domain: String
    static let className = String(describing: VPResponseMetadata.self)
    
    public init(jws: String, signatureAlgorithm: String, publicKey: String, domain: String) {
        self.jws = jws
        self.signatureAlgorithm = signatureAlgorithm
        self.publicKey = publicKey
        self.domain = domain
    }
    
    func validate() throws {
        let requiredParams: [String: String] = [
            "jws": jws,
            "signatureAlgorithm": signatureAlgorithm,
            "publicKey": publicKey,
            "domain": domain
        ]
        
        for (_, value) in requiredParams {
            if value.isEmpty || value == "null" {
                throw Logger.handleException(exceptionType: "InvalidInput", fieldPath: ["vp response metadata",value], className: LdpVPResponseMetadata.className)
            }
        }
    }
}

//VpTokenForSigning - signable payload
protocol VPTokenForSigning {
    
}

public struct LdpVPTokenForSigning: VPTokenForSigning {
    let context = ["https://www.w3.org/2018/credentials/v1"]
    let type = ["VerifiablePresentation"]
    let verifiableCredential: [String]
    let id = UUIDGenerator.generateUUID()
    let holder: String
    
    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case type
        case verifiableCredential
        case id
        case holder
    }
}


// constrcutProof
protocol VpTokenBuilder {
    func build() throws -> CredentialFormatSpecificVPToken
}

class LdpVpTokenBuilder : VpTokenBuilder {
    private(set) var ldpVPResponseMetadata:  LdpVPResponseMetadata
    private(set) var ldpVPTokenForSigning:  LdpVPTokenForSigning
    private(set) var nonce: String
    
    init(ldpVPResponseMetadata:  LdpVPResponseMetadata,ldpVPTokenForSigning:  LdpVPTokenForSigning, nonce: String) {
        self.ldpVPResponseMetadata = ldpVPResponseMetadata
        self.ldpVPTokenForSigning = ldpVPTokenForSigning
        self.nonce = nonce
    }
    
    func build() throws -> CredentialFormatSpecificVPToken {
        do{
            //Can it be moved to setter logic?
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


enum VPTokenType {
    case vpTokenArray([CredentialFormatSpecificVPToken])
    case vpToken(CredentialFormatSpecificVPToken)
}



class VPTokenFactory {
    private let vpResponseMetadata:  VPResponseMetadata
    private let vpTokenForSigning:  VPTokenForSigning
    private let nonce: String
    
    init(vpResponseMetadata:  VPResponseMetadata,vpTokenForSigning:  VPTokenForSigning, nonce: String) {
        self.vpResponseMetadata = vpResponseMetadata
        self.vpTokenForSigning = vpTokenForSigning
        self.nonce = nonce
    }
    func getVPTokenBuilder(credentialFormat: FormatType) throws -> VpTokenBuilder {
        if(credentialFormat == .ldp_vc){
            return LdpVpTokenBuilder(ldpVPResponseMetadata: self.vpResponseMetadata as! LdpVPResponseMetadata, ldpVPTokenForSigning: self.vpTokenForSigning as! LdpVPTokenForSigning, nonce: nonce)
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
    
}




public class AuthorizationResponseHandler {
    var vpToken: VPTokenType?
    var presentation_definition: PresentationDefinition?
    static var selectedCredentials: [String: Array<[String: Array<Any>]>] = [:]
    static var vpTokensForSigning: [FormatType: LdpVPTokenForSigning] = [:]
    
    
    func createVPToken(signedPayloads: [FormatType:VPResponseMetadata], presentation_submission: PresentationSubmission) throws {
        var vpTokenOfCredentials: [CredentialFormatSpecificVPToken] = []
        
        for(credentialFormat, vpResponseMetata) in signedPayloads{
            do {
                //TODO: Get nonce from AuthRequest
                let vpTokenBuilder = try VPTokenFactory(vpResponseMetadata: vpResponseMetata, vpTokenForSigning: AuthorizationResponseHandler.vpTokensForSigning[credentialFormat]!, nonce: "String").getVPTokenBuilder(credentialFormat: credentialFormat)
                let credentialSpecificVPToken = try vpTokenBuilder.build()
                vpTokenOfCredentials.append(credentialSpecificVPToken)
            }
            catch {
                throw error
            }
        }
        
        self.vpToken = vpTokenOfCredentials.count == 1 ? VPTokenType.vpToken(vpTokenOfCredentials.first!) : VPTokenType.vpTokenArray(vpTokenOfCredentials)
    }
    
    func createAuthorizationReponse() -> AuthorizationResponse1 {
        //TODO: Based on Auth request response_type call stuff accordingly
        //        createVPToken(signedPayloads: <#T##[FormatType : VPResponseMetadata]#>, presentation_submission: <#T##PresentationSubmission#>)
        return AuthorizationResponse1(vpToken: self.vpToken!, presentation_submission: PresentationSubmission(definition_id: "String", descriptor_map: [DescriptorMap(id: "", format: FormatType.ldp_vc, path: "String")]))
    }
}

