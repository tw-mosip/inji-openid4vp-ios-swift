import Foundation

struct AnyCredentialFormatSpecificSigningData: Encodable {
    let credentialFormatSpecificSigningData: CredentialFormatSpecificSigningData
    
    func encode(to encoder: Encoder) throws {
        try credentialFormatSpecificSigningData.encode(to: encoder)
    }
    
    static func encodeShapesToJSONString(shapes: [FormatType: AnyCredentialFormatSpecificSigningData]) -> String? {
        let encoder = JSONEncoder()
        //        encoder.outputFormatting = .prettyPrinted
        
        if let jsonData = try? encoder.encode(shapes) {
            return String(data: jsonData, encoding: .utf8)
        }
        return nil
    }
}

protocol CredentialFormatSpecificSigningData : Encodable {
    static func create(credentialsArray: Array<String>) -> CredentialFormatSpecificSigningData
}

struct LdpVpSpecificSigningData : CredentialFormatSpecificSigningData, Encodable {
    let context = ["https://www.w3.org/2018/credentials/v1"]
    let type = ["VerifiablePresentation"]
    let verifiableCredential: [String]
    let id = UUIDGenerator.generateUUID()
    let holder: String
    
    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case type
        case verifiableCredential
        case id
        case holder
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(context, forKey: .context)
        try container.encode(type, forKey: .type)
        try container.encode(verifiableCredential, forKey: .verifiableCredential)
        try container.encode(id, forKey: .id)
        try container.encode(holder, forKey: .holder)
    }
    
    
    static func create(credentialsArray: Array<String>) -> any CredentialFormatSpecificSigningData {
        return LdpVpSpecificSigningData(verifiableCredential: credentialsArray, holder: "")
    }
}

/**
 selectedVcs
 {
 input_descriptorId: [
 {"ldp_vc": [....]}
 ]
 }
 */

class CredentialFormatSpecificSigningDataMapCreator {
    
    
    static func create(selectedCredentials: [String: Array<[String: Array<Any>]>]) throws -> [FormatType: CredentialFormatSpecificSigningData] {
        var signablePayloads: [FormatType: CredentialFormatSpecificSigningData] = [:]
        var groupedVcs: [FormatType: Any] = [:]
        
        // iterate selected credentials
        for(inputDescriptorId, matchingVcs) in selectedCredentials {
            do {
                try matchingVcs.forEach { matchingVcsGroupedByCredentialFormat in
                    for(format, matchingVcOfFormat) in matchingVcsGroupedByCredentialFormat {
                        //construct format type
                        var formatType: FormatType? = nil
                        if(format == FormatType.ldp_vc.rawValue){
                            formatType = .ldp_vc
                        }
                        guard formatType != nil else {
                            throw AuthorizationResponseException.unsupportedFormatOfLibrary
                        }
                        //group all the vp formats togetehr to pass to signable payload creation
                        if(groupedVcs[formatType!] == nil){
                            groupedVcs[formatType!] = matchingVcOfFormat
                        } else {
                            var existingData = groupedVcs[formatType!] as? Array<Any>
                            existingData?.append(contentsOf: matchingVcOfFormat)
                            groupedVcs.updateValue(existingData!, forKey: formatType!)
                        }
                    }
                }
            } catch {
                throw error
            }
        }
        
        //group all formats ones together, call specfic creator and pass the grouped credentials
        for(credentialFormat, credentialsArray) in groupedVcs {
            if(credentialFormat == FormatType.ldp_vc){
                signablePayloads[credentialFormat] = ( LdpVpSpecificSigningData.create(credentialsArray: credentialsArray as! Array<String>))
            } else {
                throw AuthorizationResponseException.unsupportedFormatOfLibrary
            }
        }
        
        return signablePayloads
    }
}

