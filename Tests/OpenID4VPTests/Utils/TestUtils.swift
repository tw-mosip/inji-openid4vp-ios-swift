import Foundation
@testable import OpenID4VP

func createVerifiers(from verifierList: [[String: Any]]) -> [Verifier] {
    var verifiers: [Verifier] = []

    for verifierData in verifierList {
        if let clientId = verifierData["client_id"] as? String,
           let responseUris = verifierData["response_uris"] as? [String] {
            let verifier = Verifier(clientId: clientId, responseUris: responseUris)
            verifiers.append(verifier)
        }
    }

    return verifiers
}

func CheckNoThrow<T>(
  _ expression: @autoclosure () throws -> T,
  _ message: @autoclosure () -> String = "",
  file: StaticString = (#filePath),
  line: UInt = #line
) -> T? {
  var r: T?
  XCTAssertNoThrow(
    try { r = try expression() }(), message(), file: file, line: line)
  return r
}
