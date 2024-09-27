public struct VpTokenForSigning: Encodable {
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

