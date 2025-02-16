import Foundation
import XCTest
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


func createEncodedAuthorizationRequest(requestParams: [String: Any], verifierSentAuthRequestByReference: Bool? = false) -> String{
    var queryParams = requestParams
    func addAsJSONParam(_ paramName: String) {
        if let data = queryParams[paramName],
           let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            queryParams[paramName] = jsonString
        }
        
    }
    // Convert presentation_definition & client_metadata to JSON string if provided
    addAsJSONParam("presentation_definition")
    addAsJSONParam("client_metadata")
    
    
    var queryString = queryParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
    
    // Handle verifierSentAuthRequestByReference
    if let verifierSentAuthRequestByReference = verifierSentAuthRequestByReference, verifierSentAuthRequestByReference {
        queryString += "&request_uri=https://mock-verifier.com/auth-request"
    }
    
    guard let queryData = queryString.data(using: .utf8) else { return "" }
    let base64Encoded = queryData.base64EncodedString()
    
    return "OPENID4VP://authorize?"+base64Encoded
}
