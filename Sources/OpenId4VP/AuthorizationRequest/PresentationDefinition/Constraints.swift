import Foundation

struct Constraints: Codable {
    var fields: [Fields]?
    var limitDisclosure: LimitDisclosure?
    
    enum CodingKeys: String, CodingKey {
        case fields
        case limitDisclosure
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.fields = try container.decodeIfPresent([Fields].self, forKey: .fields)
        self.limitDisclosure = try container.decodeIfPresent(LimitDisclosure.self, forKey: .limitDisclosure)
        
        try validate()
    }
    
    func validate() throws {
        guard let fields = fields, !fields.isEmpty else {
            Logger.error("Constraints : Fields should not be empty.")
            throw AuthorizationRequestException.invalidPresentationDefinition
        }
        
        for field in fields {
            try field.validate()
        }
        
        if let limitDisclosure = limitDisclosure {
            guard limitDisclosure == .required || limitDisclosure == .preferred else {
                Logger.error("Constraints : LimitDisclosure should be either 'required' or 'preferred'.")
                throw AuthorizationRequestException.invalidInput(key: "limit disclosure")
            }
        }
    }
}
