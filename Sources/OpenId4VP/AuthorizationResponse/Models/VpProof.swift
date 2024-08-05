struct VpProof: Encodable{
    let type: String
    let challenge: String
    let domain: String
    let jws: String
    let proofPurpose: String
    let verificationMethod: String
}
