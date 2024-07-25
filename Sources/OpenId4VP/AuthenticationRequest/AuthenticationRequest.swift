import Foundation

struct AuthenticationRequest {
    public let clientId: String
    public let presentation_definition: String
    public let response_type: String
    public let response_mode: String
    public let nonce: String
    public let state: String
    public let response_uri: String
    
    init(clientId: String, presentation_definition: String,response_type : String,response_mode: String, nonce: String, state: String,response_uri: String ) {
        self.clientId = clientId
        self.presentation_definition = presentation_definition
        self.response_type = response_type
        self.response_mode = response_mode
        self.nonce = nonce
        self.state = state
        self.response_uri = response_uri
    }
    
    static func constructAuthorizationRequest(requestParams: [String:String]) throws -> AuthenticationRequest?{
        
        if let values = requestParams.values(forKeys: PresentationDefinitionParams.allKeys) {
            return AuthenticationRequest(
                clientId: values[0],
                presentation_definition: values[1],
                response_type: values[2],
                response_mode: values[3],
                nonce: values[4],
                state: values[5],
                response_uri: values[6]
            )
        } else {
            throw AuthorizationRequestErrors.invalidAuthorizationRequest
        }
    }
}
