import Foundation

struct InputDescriptor: Codable {
    var id: String
    var name: String?
    var purpose: String?
    var format: Format?
    var constraints: Constraints
    var missingFields: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case purpose
        case format
        case constraints
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var missingFields: [String] = []
        
        if let id = try container.decodeIfPresent(String.self, forKey: .id) {
            self.id = id
        } else {
            self.id = ""
            missingFields.append("Id should be present")
        }
        
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.purpose = try container.decodeIfPresent(String.self, forKey: .purpose)
        
        if let format = try container.decodeIfPresent(Format.self, forKey: .format) {
            self.format = format
            if let formatMissingFields = format.missingFields {
                missingFields.append(contentsOf: formatMissingFields.map { "Format: \($0)" })
            }
        } else {
            self.format = nil
        }
        
        if let constraints = try container.decodeIfPresent(Constraints.self, forKey: .constraints) {
            self.constraints = constraints
            if let constraintsMissingFields = constraints.missingFields {
                missingFields.append(contentsOf: constraintsMissingFields.map { "Constraints: \($0)" })
            }
        } else {
            self.constraints = Constraints()
            missingFields.append("constraints")
        }
        self.missingFields = missingFields
    }
    
    func validate() -> [String] {
        var errors: [String] = []
        
        if id.isEmpty {
            errors.append("ID must not be empty.")
        }
        
        if let format = format {
            let formatErrors = format.validate()
            if !formatErrors.isEmpty {
                errors.append(contentsOf: formatErrors.map { "Format: \($0)" })
            }
        }
        
        let constraintErrors = constraints.validate()
        if !constraintErrors.isEmpty {
            errors.append(contentsOf: constraintErrors.map { "Constraints: \($0)" })
        }
        
        return errors
    }
}
