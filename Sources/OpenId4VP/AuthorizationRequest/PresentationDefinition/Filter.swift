import Foundation

struct Filter: Codable {
    var type: String
    var pattern: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case pattern
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let type = try container.decodeIfPresent(String.self, forKey: .type) else {
            throw AuthorizationRequestErrors.invalidPresentationDefinition
        }
        
        guard let pattern = try container.decodeIfPresent(String.self, forKey: .pattern) else {
            throw AuthorizationRequestErrors.invalidPresentationDefinition
        }
        
        self.type = type
        self.pattern = pattern
        
        try validate()
    }
    
    func validate() throws {
        guard !type.isEmpty || !pattern.isEmpty else {
            throw AuthorizationRequestErrors.invalidPresentationDefinition
        }
    }
}
