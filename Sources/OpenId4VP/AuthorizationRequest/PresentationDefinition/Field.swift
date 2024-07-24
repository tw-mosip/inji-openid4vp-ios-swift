import Foundation

struct Field: Codable {
    var path: [String]
    var id: String?
    var name: String?
    var purpose: String?
    var filter: Filter?
    var optional: Bool?
    var missingFields: [String]?
    
    enum CodingKeys: String, CodingKey {
        case path
        case id
        case name
        case purpose
        case filter
        case optional
    }
    
    init(path: [String], id: String? = nil, name: String? = nil, purpose: String? = nil, filter: Filter? = nil, optional: Bool? = nil) {
        self.path = path
        self.id = id
        self.name = name
        self.purpose = purpose
        self.filter = filter
        self.optional = optional
        self.missingFields = nil
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var missingFields: [String] = []
        
        if let path = try container.decodeIfPresent([String].self, forKey: .path) {
            self.path = path
        } else {
            self.path = []
            missingFields.append("Path should be present")
        }
        
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.purpose = try container.decodeIfPresent(String.self, forKey: .purpose)
        
        if let filter = try container.decodeIfPresent(Filter.self, forKey: .filter) {
            self.filter = filter
            if let filterMissingFields = filter.missingFields {
                missingFields.append(contentsOf: filterMissingFields.map { "Filter: \($0)" })
            }
        } else {
            self.filter = nil
        }
        
        self.optional = try container.decodeIfPresent(Bool.self, forKey: .optional)
        
        self.missingFields = missingFields
    }
    
    func validate() -> [String] {
        var errors: [String] = []
        
        if path.isEmpty {
            errors.append("Path must not be empty.")
        } else {
            for (index, p) in path.enumerated() {
                if !(p.starts(with: "$.") || p.starts(with: "$[")) {
                    errors.append("Path \(index + 1) is invalid.")
                }
            }
        }
        
        if let filter = filter, !filter.validate() {
            errors.append("Filter is invalid.")
        }
        
        return errors
    }
}
