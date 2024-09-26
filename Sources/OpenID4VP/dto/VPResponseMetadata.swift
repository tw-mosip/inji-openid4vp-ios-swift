public struct VPResponseMetadata {
    let jws: String
    let signatureAlgorithm: String
    let publicKey: String
    let domain: String
    
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
                throw AuthorizationRequestException.invalidInput(fieldName: "\(value)")
            }
        }
    }
}
