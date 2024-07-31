import Foundation

struct PresentationDefinition: Decodable {
    var id: String
    var name: String?
    var purpose: String?
    var input_descriptors: [InputDescriptor]
    var format: Format?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case purpose
        case input_descriptors
        case format
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let id = try container.decodeIfPresent(String.self, forKey: .id) else {
            throw AuthorizationRequestErrors.invalidPresentationDefinition
        }
        
        guard let inputDescriptors = try container.decodeIfPresent([InputDescriptor].self, forKey: .input_descriptors) else {
            throw AuthorizationRequestErrors.invalidPresentationDefinition
        }
        
        self.id = id
        self.input_descriptors = inputDescriptors
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.purpose = try container.decodeIfPresent(String.self, forKey: .purpose)
        self.format = try container.decodeIfPresent(Format.self, forKey: .format)
        
        try validate()
    }
    
    func validate() throws {
        guard !id.isEmpty else {
            throw AuthorizationRequestErrors.invalidPresentationDefinition
        }
        
        guard !input_descriptors.isEmpty else {
            throw AuthorizationRequestErrors.invalidPresentationDefinition
        }
        
        for descriptor in input_descriptors {
            try descriptor.validate()
        }
        
        if let format = format {
            try format.validate()
        }
    }
}
