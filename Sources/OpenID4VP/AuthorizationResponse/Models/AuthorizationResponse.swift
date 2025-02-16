import Foundation

public struct AuthorizationResponse {
    let vpToken: VPTokenType
    let presentation_submission: PresentationSubmission
    static let className = String(describing: AuthorizationResponse.self)

    init(vpToken: VPTokenType, presentation_submission: PresentationSubmission) {
        self.vpToken = vpToken
        self.presentation_submission = presentation_submission
    }

    func encodedItems() throws -> [(name: String, value: String)] {
        let encodedVPTokenData: String, encodedPresentationSubmissionData: String
        
        encodedVPTokenData =  String(data: vpToken.encoded!, encoding: .utf8) ?? ""
        
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
            })

        case .vpToken(let token):
            return try? encoder.encode(token)
        }
    }
}
