public struct VPResponseMetadata {
    let jws: String
    let signatureAlgorithm: String
    let publicKey: String
    let domain: String
    
    func validate() throws {
        let requiredParams: [String: String] = [
            "jws": jws,
            "signatureAlgorithm": signatureAlgorithm,
            "publicKey": publicKey,
            "domain": domain
        ]
        
        for (_, value) in requiredParams {
            if value.isEmpty || value == "null" {
                throw AuthorizationRequestException.invalidInput(fieldName: "\(value)")
            }
        }
    }
}
