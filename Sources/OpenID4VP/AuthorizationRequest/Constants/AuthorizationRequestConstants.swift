import Foundation

enum ClientIdScheme: String, Codable, CaseIterable{
    case preRegistered = "pre-registered"
    case redirectUri = "redirect_uri"
    case did = "did"
}

enum ResponseMode : String {
    case direct_post = "direct_post"
}

enum ResponseType: String {
    case vp_token = "vp_token"
}
