import Foundation

class VPTokenFactory {
    private let vpResponseMetadata:  VpResponseMetadata
    private let vpTokenForSigning:  CredentialFormatSpecificSigningData
    private let nonce: String

    init(vpResponseMetadata:  VpResponseMetadata,vpTokenForSigning:  CredentialFormatSpecificSigningData, nonce: String) {
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
}
