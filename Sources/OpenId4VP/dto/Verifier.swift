import Foundation

public struct Verifier {
    public let clientId: String
    public let redirectUri: [String]

    init(clientId: String, redirectUri: [String]) {
        self.clientId = clientId
        self.redirectUri = redirectUri
    }
}
