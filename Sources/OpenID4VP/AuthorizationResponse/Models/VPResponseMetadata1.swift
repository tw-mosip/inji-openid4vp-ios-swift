//
//  File.swift
//  
//
//  Created by Kiruthika Jeyashankar on 03/02/25.
//

import Foundation

//VPResponseMetadata - signed data + other response metadata for creation of the vp_token
public protocol VpResponseMetadata1 {
    
}

class LdpVPResponseMetadata : VpResponseMetadata1 {
    let jws: String
    let signatureAlgorithm: String
    let publicKey: String
    let domain: String
    static let className = String(describing: VPResponseMetadata.self)
    
    public init(jws: String, signatureAlgorithm: String, publicKey: String, domain: String) {
        self.jws = jws
        self.signatureAlgorithm = signatureAlgorithm
        self.publicKey = publicKey
        self.domain = domain
    }
    
    func validate() throws {
        let requiredParams: [String: String] = [
            "jws": jws,
            "signatureAlgorithm": signatureAlgorithm,
            "publicKey": publicKey,
            "domain": domain
        ]
        
        for (_, value) in requiredParams {
            if value.isEmpty || value == "null" {
                throw Logger.handleException(exceptionType: "InvalidInput", fieldPath: ["vp response metadata",value], className: LdpVPResponseMetadata.className)
            }
        }
    }
}
