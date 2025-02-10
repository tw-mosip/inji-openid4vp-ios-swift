//
//  File.swift
//  
//
//  Created by Kiruthika Jeyashankar on 07/02/25.
//

import Foundation

public struct AuthorizationResponse {
    let vpToken: VPTokenType
    let presentation_submission: PresentationSubmission
    static let className = String(describing: AuthorizationResponse.self)

    init(vpToken: VPTokenType, presentation_submission: PresentationSubmission) {
        self.vpToken = vpToken
        self.presentation_submission = presentation_submission
    }

    //Add state field
    func encodedItems() throws -> [(name: String, value: String)] {
        //TODO: This has so much of Hard coding Can it be removed?
        let encodedVPTokenData: String, encodedPresentationSubmissionData: String
        do {
            encodedVPTokenData = try String(data: vpToken.encoded!, encoding: .utf8) ?? ""
        } catch let error {
            throw Logger.handleException(exceptionType: "JsonEncodingFailed", message: error.localizedDescription, fieldPath: ["vp_token"], className: AuthorizationResponse.className)
        }

        do {
            encodedPresentationSubmissionData = try encodeToJsonString(self.presentation_submission)!
        } catch let error {
            throw Logger.handleException(exceptionType: "JsonEncodingFailed", message: error.localizedDescription, fieldPath: ["presentation_submission"], className: AuthorizationResponse.className)
        }

        var encodedItems : [(name: String, value: String)] = []
        encodedItems.append((name: "vp_token",value: encodedVPTokenData))
        encodedItems.append((name: "presentation_definition",value: encodedPresentationSubmissionData))
        return encodedItems
    }
}

//2 vcs -> mdoc, ldpvc -> 2 VP -> [vp_ldp_vp, mdoc_vp]
//2 vcs -> ldp_vcs -> 1 VP -> vp_ldp_vp
/**
 vp_token: "{.....all fields - context}"
 */
enum VPTokenType{
    case vpTokenArray([CredentialFormatSpecificVPToken])
    case vpToken(CredentialFormatSpecificVPToken)

    enum CodingKeys: String, CodingKey {
        case type
        case value
    }
}

extension VPTokenType {
    var encoded: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        switch self {
        case .vpTokenArray(let tokens):
            return try? encoder.encode(tokens.map{
                try encoder.encode($0)
            }) // Encodes the array directly

        case .vpToken(let token):
            return try? encoder.encode(token) // Encodes the single token
        }
    }
}
