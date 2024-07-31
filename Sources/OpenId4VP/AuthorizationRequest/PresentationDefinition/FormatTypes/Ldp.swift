import Foundation

struct LDPFormat: Codable {
    var proofType: [String]
    
    enum CodingKeys: String, CodingKey {
        case proofType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let proofType = try container.decodeIfPresent([String].self, forKey: .proofType) else {
            throw AuthorizationRequestErrors.invalidPresentationDefinition
        }
        
        self.proofType = proofType
        
        try validate()
    }
    
    func validate() throws {
        guard !proofType.isEmpty else {
            throw AuthorizationRequestErrors.invalidPresentationDefinition
        }
    }
}
