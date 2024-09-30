import Foundation

public struct Verifier {
    public let clientId: String
    public let responseUris: [String]

    public init(clientId: String, responseUris: [String]) {
        self.clientId = clientId
        self.responseUris = responseUris
    }
}
