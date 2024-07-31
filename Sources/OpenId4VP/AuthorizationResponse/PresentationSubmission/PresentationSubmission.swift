struct VpProof{
    let type: String
    let created: String
    let challenge: String
    let domain: String
    let jws: String
    let proofPurpose: String
    let verificationMethod: String
}

struct VpToken{
    let context: [String]
    let type: [String]
    let verifiableCredential: [String]
    let id: String
    let holder: String
    
    enum CodingKeys: String, CodingKey {
           case context = "@context"
       }
}

struct VpTokenWithProof{
    let vp: VpToken
    let proof: String
}

struct DescriptorMap{
    var id: String
    var format: String
    var path: String
}

struct PresentationSubmission {
    let id: String = "123"
    let definition_id: String
    let descriptor_map: [DescriptorMap]
}
