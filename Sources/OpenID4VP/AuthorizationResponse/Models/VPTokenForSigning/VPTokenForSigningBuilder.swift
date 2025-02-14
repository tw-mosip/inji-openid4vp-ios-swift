import Foundation

/**
 selectedVcs
 {
 input_descriptorId: [
 {"ldp_vc": [....]}
 ]
 }
 */

public class CredentialFormatSpecificSigningDataMapCreator {
    static func create(selectedCredentials: [String: [String: Array<Any>]]) throws -> [FormatType: CredentialFormatSpecificSigningData] {
        var signablePayloads: [FormatType: CredentialFormatSpecificSigningData] = [:]
        var groupedVcs: [FormatType: Array<Any>] = [:]
        /**
         {id1: {
f1: [...]
         }, id2: {
f1: [...]
         }}
         */
        
        // iterate selected credentials
        for(_, matchingVcs) in selectedCredentials {
            do {
                
                for(format, matchingVcOfFormat) in matchingVcs {
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
                        var existingData = groupedVcs[formatType!]
                        existingData?.append(contentsOf: matchingVcOfFormat)
                        groupedVcs.updateValue(existingData!, forKey: formatType!)
                    }
                }
            } catch {
                throw error
            }
        }
        
        //group all formats ones together, call specfic creator and pass the grouped credentials
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
