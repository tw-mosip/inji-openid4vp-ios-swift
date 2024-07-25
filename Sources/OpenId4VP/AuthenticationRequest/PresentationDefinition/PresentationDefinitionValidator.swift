import Foundation

struct PresentationDefinitionValidator {
    
    static func validate(presentatioDefinition: String) throws {
        guard let jsonData = presentatioDefinition.data(using: .utf8) else {
            throw AuthorizationRequestErrors.jsonDecodingFailed
        }
        
        let decoder = JSONDecoder()
        do {
            _ = try decoder.decode(PresentationDefinition.self, from: jsonData)
        } catch {
            throw AuthorizationRequestErrors.invalidPresentationDefinition
        }
    }
}
