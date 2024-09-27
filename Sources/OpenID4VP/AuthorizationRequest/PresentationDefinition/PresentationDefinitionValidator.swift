import Foundation

struct PresentationDefinitionValidator {
    
    static func validate(presentatioDefinition: String) throws -> PresentationDefinition {
        
        Logger.getLogTag(className: String(describing: self))
        
        guard let jsonData = presentatioDefinition.data(using: .utf8) else {
            Logger.error("Json Decoding of presentationDefinition failed.")
            throw AuthorizationRequestException.jsonDecodingFailed
        }
        
        do {
          return try JSONDecoder().decode(PresentationDefinition.self, from: jsonData)
        } catch {
            throw AuthorizationRequestException.invalidPresentationDefinition
        }
    }
}
