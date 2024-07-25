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

struct LimitDisclosure {
    static let required = "required"
    static let preferred = "preferred"
}

struct Path {
    static let dollorAndDotPrefix = "$."
    static let dollorAndSquareBracketPrefix = "$["
}
