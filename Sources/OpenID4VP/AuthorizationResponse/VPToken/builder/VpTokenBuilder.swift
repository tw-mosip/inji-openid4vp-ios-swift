//
//  File.swift
//  
//
//  Created by Kiruthika Jeyashankar on 07/02/25.
//

import Foundation

protocol VpTokenBuilder {
    func build() throws -> CredentialFormatSpecificVPToken
}
