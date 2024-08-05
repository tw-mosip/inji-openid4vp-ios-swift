import Foundation

struct PresentationDefinitionValidator {
    
    static func validate(presentatioDefinition: String) throws -> PresentationDefinition {
        guard let jsonData = presentatioDefinition.data(using: .utf8) else {
            Logger.error("Decoding of presentationDefinition failed.")
            throw AuthenticationResponseErrors.jsonDecodingFailed
        }
        
        let decoder = JSONDecoder()
        do {
          return try decoder.decode(PresentationDefinition.self, from: jsonData)
            
            
        } catch {
            Logger.error("Presentation definition in AuthorizationRequest is invalid.")
            throw AuthenticationResponseErrors.invalidPresentationDefinition
        }
    }
}
