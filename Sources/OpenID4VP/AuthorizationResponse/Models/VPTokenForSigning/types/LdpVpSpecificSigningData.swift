//
//  File.swift
//  
//
//  Created by Kiruthika Jeyashankar on 04/02/25.
//

import Foundation

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
