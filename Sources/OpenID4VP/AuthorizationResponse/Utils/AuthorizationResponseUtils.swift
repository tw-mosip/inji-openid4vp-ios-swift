import Foundation


func encodeQueryValue(_ value: String) -> String {
    var allowedCharacterSet = CharacterSet.urlQueryAllowed
    allowedCharacterSet.remove("+")
    return value.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? value
}

func encodeToJsonString<T: Encodable>(_ value: T) throws -> String? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .withoutEscapingSlashes
    let jsonData = try encoder.encode(value)
    let jsonresponse: String? = String(data: jsonData, encoding: .utf8)
    return jsonresponse
}


//TODO: Test encoding logic separately
func encodeVPTokenForSigning(_ vpTokensForSigning: [FormatType: CredentialFormatSpecificSigningData]) throws -> [String : String] {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .withoutEscapingSlashes
    var formatted: [String: String] = [:]
    for (key,value) in vpTokensForSigning {
        let encodedContent = try encoder.encode(value)
        formatted[key.rawValue] = String(data: encodedContent, encoding: .utf8)
    }
    
//    let encoder1 = JSONEncoder()
//    let jsonData = try encoder1.encode(formatted)
//    let jsonresponse: String? = String(data: jsonData, encoding: .utf8)
//    let jsonresponse: String? = String(data: jsonData, encoding: .utf8)
    return formatted
    
}
