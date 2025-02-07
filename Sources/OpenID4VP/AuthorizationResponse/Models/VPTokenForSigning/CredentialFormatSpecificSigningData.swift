//
//  File.swift
//  
//
//  Created by Kiruthika Jeyashankar on 04/02/25.
//

import Foundation

protocol CredentialFormatSpecificSigningData : Encodable {
    static func create(credentialsArray: Array<String>) -> CredentialFormatSpecificSigningData
}
