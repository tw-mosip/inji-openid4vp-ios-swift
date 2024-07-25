import Foundation

struct InputDescriptor: Codable {
    var id: String
    var name: String?
    var purpose: String?
    var format: Format?
    var constraints: Constraints
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case purpose
        case format
        case constraints
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let id = try container.decodeIfPresent(String.self, forKey: .id) else {
            throw AuthorizationRequestErrors.invalidPresentationDefinition
        }
        
        guard let constraints = try container.decodeIfPresent(Constraints.self, forKey: .constraints) else {
            throw AuthorizationRequestErrors.invalidPresentationDefinition
        }
        
        self.id = id
        self.constraints = constraints
        self.format = try container.decodeIfPresent(Format.self, forKey: .format)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.purpose = try container.decodeIfPresent(String.self, forKey: .purpose)
    }
    
    func validate() throws {
        guard !id.isEmpty else {
            throw AuthorizationRequestErrors.invalidPresentationDefinition
        }
        
        if let format = format {
            try format.validate()
        }
        
        try constraints.validate()
    }
}
