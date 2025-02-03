/**
 vp token -> In case Presentation Exchange was used, it is a JSON String or JSON object that MUST contain a single Verifiable Presentation or an array of JSON Strings and JSON objects each of them containing a Verifiable Presentations. Each Verifiable Presentation MUST be represented as a JSON string (that is a base64url-encoded value) or a JSON object depending on a format as defined in Appendix B. When a single Verifiable Presentation is returned, the array syntax MUST NOT be used.
 */
public struct VpToken: Encodable {
    let context: [String]
    let type: [String]
    let verifiableCredential: [String]
    let id: String
    let holder: String
    let proof: Proof
    
    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case type
        case verifiableCredential
        case id
        case holder
        case proof
    }
    
    static func constructVpToken(signingVPToken: VpTokenForSigning, proof: Proof) -> Self {
        return VpToken(
            context: signingVPToken.context,
            type: signingVPToken.type,
            verifiableCredential: signingVPToken.verifiableCredential,
            id: signingVPToken.id,
            holder: signingVPToken.holder,
            proof: proof
        )
    }
}
