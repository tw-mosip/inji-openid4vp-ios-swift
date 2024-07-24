import Foundation

struct LDPFormat: Codable {
    var proof_type: [String]
    var missingFields: [String]?

    enum CodingKeys: String, CodingKey {
        case proof_type
    }

    init(proof_type: [String]) {
        self.proof_type = proof_type
        self.missingFields = nil
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var missingFields: [String] = []

        if let proof_type = try container.decodeIfPresent([String].self, forKey: .proof_type) {
            self.proof_type = proof_type
        } else {
            self.proof_type = []
            missingFields.append("Proof type should be present")
        }

        self.missingFields = missingFields
    }
    
    func validate() -> [String] {
        var errors: [String] = []
        
        if proof_type.isEmpty {
            errors.append("Proof type list must not be empty.")
        }
        
        return errors
    }
}
