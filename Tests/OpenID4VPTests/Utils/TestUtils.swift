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

//func createAuthorizationRequestObject(requestParams: [String,Any],clientIdSchme: ClientIdScheme) -> String {
    //TODO: separae funciton for JWT creation - JWT util
//    guard let privateKeyPEM = """
//        -----BEGIN EC PRIVATE KEY-----
//        MHcCAQEEIBLrwMSdYN6WJNzDP3dmU/6Tr/WToKrFlR8ry8dQVRa6oAoGCCqGSM49
//        AwEHoUQDQgAEjNT4kicXe3LRmRtbR+ehJf9FNftL3y0FN2fIp9NZcEVOt0CVzMzD
//        0/zrlkDt4OGAvZR/UMY6EPhHlsNuUnANwA==
//        -----END EC PRIVATE KEY-----
//        """.data(using: .utf8) else { return "" }
//    switch clientIdSchme {
//    case .did:
//        let privateKey = try? ECPublicKey(pemEncoded: privateKeyPEM)
//        let signingKey = try? ECPrivateKey(pemEncoded: privateKeyPEM)
//        guard let key = signingKey else {
//            return ""
//        }
//        let header = JWSHeader(algorithm: .ES256)
//        guard let payloadData = try? JSONSerialization.data(withJSONObject: requestParams, options: []),
//              let payload = Payload(payloadData) else {
//            return ""
//        }
//        
//        do {
//            let jwt = try JWS(header: header, payload: payload, privateKey: key)
//            let jwtString = jwt.compactSerializedString
//            return jwtString
//        } catch {
//            return ""
//        }
//        
//    default:
//        return ""
//    }
//    return ""
//}
