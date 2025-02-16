import Foundation

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
