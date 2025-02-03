//
//  File.swift
//  
//
//  Created by Kiruthika Jeyashankar on 27/01/25.
//

import Foundation

public struct LdpVpToken: CredentialFormatSpecificVPToken, Encodable {
    let context: [String]
    let type: [String]
    let verifiableCredential: [String]
    let id: String
    let holder: String
    let proof: Proof
    static let internalPath : String = "verifiableCredential"
    
    init(context: [String], type: [String], verifiableCredential: [String], id: String, holder: String, proof: Proof) {
        self.context = context
        self.type = type
        self.verifiableCredential = verifiableCredential
        self.id = id
        self.holder = holder
        self.proof = proof
    }
    
    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case type
        case verifiableCredential
        case id
        case holder
        case proof
    }
    
    static func create(ldpVPResponseMetadata:  LdpVPResponseMetadata,ldpVPTokenForSigning:  LdpVpSpecificSigningData, nonce: String) throws -> CredentialFormatSpecificVPToken {
        do{
            //TODO: Can it be moved to setter logic?
            try ldpVPResponseMetadata.validate()
            let proof = Proof.constructProof(from: ldpVPResponseMetadata, challenge: nonce)
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

