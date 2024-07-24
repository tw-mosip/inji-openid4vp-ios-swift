import Foundation

struct JWTFormat: Codable {
    var alg: [String]
    var missingFields: [String]?

    enum CodingKeys: String, CodingKey {
        case alg
    }

    init(alg: [String]) {
        self.alg = alg
        self.missingFields = nil
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var missingFields: [String] = []
        
        if let alg = try container.decodeIfPresent([String].self, forKey: .alg) {
            self.alg = alg
        } else {
            self.alg = []
            missingFields.append("alg should be present")
        }
        
        self.missingFields = missingFields
    }
    
    func validate() -> [String] {
        var errors: [String] = []
        
        if alg.isEmpty {
            errors.append("Algorithm list must not be empty.")
        }
        
        return errors
    }
}
