import Foundation

struct PresentationDefinitionParams {
    static let clientid = "client_id"
    static let presentationdefinition = "presentation_definition"
    static let responsetype = "response_type"
    static let responseMode = "response_mode"
    static let nonce = "nonce"
    static let state = "state"
    static let responseUri = "response_uri"
    
    static let allKeys = [
        clientid,
        presentationdefinition,
        responsetype,
        responseMode,
        nonce,
        state,
        responseUri
    ]
}

struct PresentationDefinitionError {
    static let PresentationDefinitionErrors = "presentationDefinitionErrors"
}

struct VerifierParams {
    static let redirect_uri = "redirect_uri"
}
