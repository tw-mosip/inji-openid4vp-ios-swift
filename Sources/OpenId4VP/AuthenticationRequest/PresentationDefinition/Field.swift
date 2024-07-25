import Foundation

struct Field: Codable {
    var path: [String]
    var id: String?
    var name: String?
    var purpose: String?
    var filter: Filter?
    var optional: Bool?
    
    enum CodingKeys: String, CodingKey {
        case path
        case id
        case name
        case purpose
        case filter
        case optional
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let path = try container.decodeIfPresent([String].self, forKey: .path) else {
            throw AuthorizationRequestErrors.invalidPresentationDefinition
        }
        
        self.path = path
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.purpose = try container.decodeIfPresent(String.self, forKey: .purpose)
        self.filter = try container.decodeIfPresent(Filter.self, forKey: .filter)
        self.optional = try container.decodeIfPresent(Bool.self, forKey: .optional)
        
        try validate()
    }
    
    func validate() throws {
        guard !path.isEmpty else {
            throw AuthorizationRequestErrors.invalidPresentationDefinition
        }
        
        for p in path {
            if !(p.starts(with: Path.dollorAndDotPrefix) || p.starts(with: Path.dollorAndSquareBracketPrefix)) {
                throw AuthorizationRequestErrors.invalidPresentationDefinition
            }
        }
        
        if let filter = filter {
            try filter.validate()
        }
    }
}
