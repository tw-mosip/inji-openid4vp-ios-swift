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
            Logger.error("Filter : type should be present.")
            throw AuthenticationResponseErrors.invalidPresentationDefinition
        }
        
        guard let pattern = try container.decodeIfPresent(String.self, forKey: .pattern) else {
            Logger.error("Filter : pattern should be present.")
            throw AuthenticationResponseErrors.invalidPresentationDefinition
        }
        
        self.type = type
        self.pattern = pattern
        
        try validate()
    }
    
    func validate() throws {
        guard !type.isEmpty || !pattern.isEmpty else {
            Logger.error("Filter : type or pattern is empty.")
            throw AuthenticationResponseErrors.invalidPresentationDefinition
        }
    }
}
