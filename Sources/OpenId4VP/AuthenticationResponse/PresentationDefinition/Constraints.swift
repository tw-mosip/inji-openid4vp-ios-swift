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
            Logger.error("Constraints : Fields should be present.")
            throw AuthenticationResponseErrors.invalidPresentationDefinition
        }
        
        self.fields = fields
        self.limitDisclosure = try container.decodeIfPresent(String.self, forKey: .limitDisclosure)
        
        try validate()
    }
    
    func validate() throws {
        guard let fields = fields, !fields.isEmpty else {
            Logger.error("Constraints : Fields should not be empty.")
            throw AuthenticationResponseErrors.invalidPresentationDefinition
        }
        
        for field in fields {
            try field.validate()
        }
        
        if let limitDisclosure = limitDisclosure, (limitDisclosure != LimitDisclosure.required && limitDisclosure != LimitDisclosure.preferred) {
            Logger.error("Constraints : Limit disclosure is not valid.")
            throw AuthenticationResponseErrors.invalidPresentationDefinition
        }
    }
}
