import Foundation

public func validatePresentationDefinition(presentatioDefinition: String) throws -> [String]? {
    guard let jsonData = presentatioDefinition.data(using: .utf8) else {
        throw AuthorizationRequestErrors.jsonDecodingFailed
    }
    
    let decoder = JSONDecoder()
    do {
        let presentationDefinition = try decoder.decode(PresentationDefinition.self, from: jsonData)
        if ((presentationDefinition.missingFields)!.isEmpty){
            return presentationDefinition.validate()
        }
        return presentationDefinition.missingFields!
    } catch {
        throw AuthorizationRequestErrors.presentationDefinitionValidationFailed
    }
}

