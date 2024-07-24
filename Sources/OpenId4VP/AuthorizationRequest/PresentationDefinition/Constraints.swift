import Foundation

struct Constraints: Codable {
    var fields: [Field]?
    var limit_disclosure: String?
    var missingFields: [String]?
    
    enum CodingKeys: String, CodingKey {
        case fields
        case limit_disclosure
    }
    
    init(fields: [Field]? = nil, limit_disclosure: String? = nil) {
        self.fields = fields
        self.limit_disclosure = limit_disclosure
        self.missingFields = nil
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var missingFields: [String] = []
        
        if let fields = try container.decodeIfPresent([Field].self, forKey: .fields) {
            self.fields = fields
            for (index, field) in fields.enumerated() {
                if let fieldMissingFields = field.missingFields {
                    missingFields.append(contentsOf: fieldMissingFields.map { "Field \(index + 1): \($0)" })
                }
            }
        } else {
            self.fields = []
        }
        
        self.limit_disclosure = try container.decodeIfPresent(String.self, forKey: .limit_disclosure)
        
        self.missingFields = missingFields
    }
    
    func validate() -> [String] {
        var errors: [String] = []
        
        if let fields = fields, fields.isEmpty {
            errors.append("Fields must not be empty.")
        } else if let fields = fields {
            for (index, field) in fields.enumerated() {
                let fieldErrors = field.validate()
                if !fieldErrors.isEmpty {
                    errors.append(contentsOf: fieldErrors.map { "Field \(index + 1): \($0)" })
                }
            }
        }
        
        if let limit_disclosure = limit_disclosure, (limit_disclosure != "required" && limit_disclosure != "preferred") {
            errors.append("Limit disclosure must be either 'required' or 'preferred'.")
        }
        
        return errors
    }
}
