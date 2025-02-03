//
//  File.swift
//  
//
//  Created by Kiruthika Jeyashankar on 28/01/25.
//

import Foundation

protocol CredentialFormatSpecificVPToken : Encodable {
    static func create(ldpVPResponseMetadata:  LdpVPResponseMetadata,ldpVPTokenForSigning:  LdpVpSpecificSigningData, nonce: String) throws -> CredentialFormatSpecificVPToken
}
