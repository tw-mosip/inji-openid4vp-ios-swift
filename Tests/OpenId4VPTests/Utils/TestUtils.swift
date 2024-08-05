import Foundation
@testable import OpenId4VP

func createVerifiers(from verifierList: [[String: Any]]) -> [[Verifier]] {
    var verifiers: [[Verifier]] = []
    
    for verifierData in verifierList {
        if let clientId = verifierData["client_id"] as? String,
           let redirectUri = verifierData["redirect_uri"] as? [String] {
            let verifier = Verifier(clientId: clientId, redirectUri: redirectUri)
            verifiers.append([verifier])
        }
    }
    
    return verifiers
}
