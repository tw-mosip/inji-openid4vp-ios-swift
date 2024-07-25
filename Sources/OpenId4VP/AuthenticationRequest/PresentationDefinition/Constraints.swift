import Foundation

struct Constraints: Codable {
    var fields: [Field]?
    var limitDisclosure: String?
    
    enum CodingKeys: String, CodingKey {
        case fields
        case limitDisclosure
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let fields = try container.decodeIfPresent([Field].self, forKey: .fields) else {
            throw AuthorizationRequestErrors.invalidPresentationDefinition
        }
        
        self.fields = fields
        self.limitDisclosure = try container.decodeIfPresent(String.self, forKey: .limitDisclosure)
        
        try validate()
    }
    
    func validate() throws {
        guard let fields = fields, !fields.isEmpty else {
            throw AuthorizationRequestErrors.invalidPresentationDefinition
        }
        
        for field in fields {
            try field.validate()
        }
        
        if let limitDisclosure = limitDisclosure, (limitDisclosure != LimitDisclosure.required && limitDisclosure != LimitDisclosure.preferred) {
            throw AuthorizationRequestErrors.invalidPresentationDefinition
        }
    }
}
