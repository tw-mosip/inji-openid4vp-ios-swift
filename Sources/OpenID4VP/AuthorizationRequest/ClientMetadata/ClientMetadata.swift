import Foundation

public struct ClientMetadata: Codable {
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
    }
    
    static func decodeAndValidateClientMetadata(clientMetadata: String) throws -> ClientMetadata {
        
        let decodedClientMetadata = try JSONDecoder().decode(ClientMetadata.self, from: clientMetadata.data(using: .utf8)!)
        
        guard !decodedClientMetadata.name.isEmpty else {
            Logger.error("ClientMetadata: name should not be empty")
            throw AuthorizationRequestException.parameterValuesAreEmpty
        }
        
        return decodedClientMetadata
    }
}
