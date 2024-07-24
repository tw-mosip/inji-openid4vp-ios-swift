import Foundation

struct Filter: Codable {
    var type: String
    var pattern: String
    var missingFields: [String]?

    enum CodingKeys: String, CodingKey {
        case type
        case pattern
    }

    init(type: String, pattern: String) {
        self.type = type
        self.pattern = pattern
        self.missingFields = nil
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var missingFields: [String] = []

        if let type = try container.decodeIfPresent(String.self, forKey: .type) {
            self.type = type
        } else {
            self.type = ""
            missingFields.append("type should be present")
        }

        if let pattern = try container.decodeIfPresent(String.self, forKey: .pattern) {
            self.pattern = pattern
        } else {
            self.pattern = ""
            missingFields.append("pattern should be present")
        }

        self.missingFields = missingFields
    }
    
    func validate() -> Bool {
        return !type.isEmpty && !pattern.isEmpty
    }
}
