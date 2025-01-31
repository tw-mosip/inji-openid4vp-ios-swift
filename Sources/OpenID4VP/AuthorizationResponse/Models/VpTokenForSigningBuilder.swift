import Foundation

protocol CredentialFormatSpecificSigningData {
    static func create(credentialsArray: Array<String>) -> CredentialFormatSpecificSigningData
}

struct LdpVpSpecificSigningData : CredentialFormatSpecificSigningData {
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
    
    
    func create(selectedCredentials: [String: Array<[String: Array<Any>]>]) throws -> [FormatType: CredentialFormatSpecificSigningData] {
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
        
        //group all formats ones together, call specfic creator the grouped ones
        for(credentialFormat, credentialsArray) in groupedVcs {
            if(credentialFormat == FormatType.ldp_vc){
                signablePayloads[credentialFormat] = LdpVpSpecificSigningData.create(credentialsArray: credentialsArray as! Array<String>)
            } else {
                throw AuthorizationResponseException.unsupportedFormatOfLibrary
            }
        }
        
        return signablePayloads
    }
}

