import Foundation

struct PresentationDefinition: Decodable {
    var id: String
    var name: String?
    var purpose: String?
    var input_descriptors: [InputDescriptor]
    var format: Format?
    var missingFields: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case purpose
        case input_descriptors
        case format
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

        if let inputDescriptors = try container.decodeIfPresent([InputDescriptor].self, forKey: .input_descriptors) {
            self.input_descriptors = inputDescriptors
            for (index, descriptor) in inputDescriptors.enumerated() {
                if let descriptorMissingFields = descriptor.missingFields {
                    missingFields.append(contentsOf: descriptorMissingFields.map { "InputDescriptor \(index + 1): \($0)" })
                }
            }
        } else {
            self.input_descriptors = []
            missingFields.append("Input descriptors should be present")
        }
        
        if let format = try container.decodeIfPresent(Format.self, forKey: .format) {
            self.format = format
            if let formatMissingFields = format.missingFields {
                missingFields.append(contentsOf: formatMissingFields.map { "Format: \($0)" })
            }
        } else {
            self.format = nil
        }
        
        self.missingFields = missingFields
    }
    
    func validate() -> [String] {
        var errors: [String] = []
        
        if id.isEmpty {
            errors.append("Id must not be empty.")
        }
        
        if input_descriptors.isEmpty {
            errors.append("Input descriptors must not be empty.")
        }
        
        if let format = format {
            let formatErrors = format.validate()
            if !formatErrors.isEmpty {
                errors.append(contentsOf: formatErrors.map { "Format: \($0)" })
            }
        }
        
        for (index, descriptor) in input_descriptors.enumerated() {
            let descriptorErrors = descriptor.validate()
            if !descriptorErrors.isEmpty {
                errors.append(contentsOf: descriptorErrors.map { "InputDescriptor \(index + 1): \($0)" })
            }
        }
        
        return errors
    }
}
