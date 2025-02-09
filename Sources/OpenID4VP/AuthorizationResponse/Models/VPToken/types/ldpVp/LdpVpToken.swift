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
}
