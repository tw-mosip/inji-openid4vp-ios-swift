struct PresentationDefinitionParams {
    static let clientid = "client_id"
    static let presentationdefinition = "presentation_definition"
    static let scope = "scope"
    static let responsetype = "response_type"
    static let responseMode = "response_mode"
    static let nonce = "nonce"
    static let state = "state"
    static let responseUri = "response_uri"
    
    static let allKeys = [
        clientid,
        presentationdefinition,
        scope,
        responsetype,
        responseMode,
        nonce,
        state,
        responseUri
    ]
}

struct LimitDisclosure {
    static let required = "required"
    static let preferred = "preferred"
}

struct Path {
    static let dollorAndDotPrefix = "$."
    static let dollorAndSquareBracketPrefix = "$["
}

struct PresentationDefinitionId {
    static let id = "presentation_definition_id"
}
