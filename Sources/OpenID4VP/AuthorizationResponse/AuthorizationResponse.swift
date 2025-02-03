import Foundation

struct AuthorizationResponse{
    static var vpTokenForSigning: [FormatType: CredentialFormatSpecificSigningData]?
    static var descriptorMap: [DescriptorMap]?
    static let className = String(describing: AuthorizationResponse.self)
    
    static func constructVpForSigning(_ credentialsMap: [String: Array<[String: Array<Any>]>]) throws -> String {
        var credentialsArray: [String] = []
        var descriptorsMap: [DescriptorMap] = []
        var path: Int = 0
        
        //        for (key,values) in credentialsMap {
        //            for vc in values {
        //                credentialsArray.append(vc)
        //                descriptorsMap.append(DescriptorMap(id: key, format: .ldp_vc, path: "$.verifiableCredential[\(path)]"))
        //                path += 1
        //            }
        //        }
        //
        //        self.descriptorMap = descriptorsMap
        
        do {
            self.vpTokenForSigning = try CredentialFormatSpecificSigningDataMapCreator.create(selectedCredentials: credentialsMap)
            //            let encoder = JSONEncoder()
            //            if let jsonData = try? encoder.encode(self.vpTokenForSigning),
            //               let jsonString = String(data: jsonData, encoding: .utf8) {
            //                print(jsonString)
            //            }
            let jsonData = try encodeVPTokenForSigning(self.vpTokenForSigning!)
            return jsonData!
        } catch let error{
            throw Logger.handleException(exceptionType: "JsonEncodingFailed", message: error.localizedDescription, fieldPath: ["vp_token_for_signing"], className: AuthorizationResponse.className)
        }
    }
    
    static private func encodeVPTokenForSigning(_ vpTokensForSigning: [FormatType: CredentialFormatSpecificSigningData]) throws -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        var    formatted: [FormatType: Data] = [:]
        for (key,value) in vpTokensForSigning {
            formatted[key] = try encoder.encode(value)
        }
        
        let jsonData = try encoder.encode(formatted)
        let jsonresponse: String? = String(data: jsonData, encoding: .utf8)
        return jsonresponse
        
        //                try vpTokensForSigning.forEach { key, value in
        //                    try encoder.encode(value, forKey: CodingKeys(stringValue: "\(key)")!)
        //                }
        
    }
    
    //TODO: shareVp -> remove this function
    //    static func shareVp(vpResponseMetadata: [String: VpResponseMetadata1], nonce: String, state: String, responseUri: String, presentationDefinitionId: String, networkManager: NetworkManaging) async throws -> String? {
    //
    ////        try vpResponseMetadata.validate()
    ////
    ////        let proof = Proof.constructProof(from: vpResponseMetadata, challenge: nonce)
    //
    //        let presentationSubmission = PresentationSubmission(definition_id: presentationDefinitionId, descriptor_map: self.descriptorMap!)
    //
    //        var formattedVPResponseMetadata: [FormatType: VpResponseMetadata1] = [:]
    //
    //        for (key, value) in vpResponseMetadata {
    //            if let enumKey = FormatType(rawValue: key) {
    //                formattedVPResponseMetadata[enumKey] = value
    //            }
    //        }
    //
    //        let vpToken = try AuthorizationResponseHandler().createVPToken(vpTokenForSigning: formattedVPResponseMetadata)
    //
    ////        return try await constructHttpRequestBody(vpToken: vpToken, presentationSubmission: presentationSubmission, responseUri: responseUri, state: state, networkManager: networkManager)
    //    }
    
    //    private static func constructHttpRequestBody(vpToken: VPTokenType, presentationSubmission: PresentationSubmission, responseUri: String, state: String, networkManager: NetworkManaging = NetworkManager.shared) async throws -> String? {
    ////        let encodedVPTokenData: String, encodedPresentationSubmissionData: String
    ////        do {
    ////            encodedVPTokenData = try encodeToJsonString(vpToken)!
    ////        } catch let error {
    ////            throw Logger.handleException(exceptionType: "JsonEncodingFailed", message: error.localizedDescription, fieldPath: ["vp_token"], className: AuthorizationResponse.className)
    ////        }
    //
    //        do {
    //            encodedPresentationSubmissionData = try encodeToJsonString(presentationSubmission)!
    //        } catch let error {
    //            throw Logger.handleException(exceptionType: "JsonEncodingFailed", message: error.localizedDescription, fieldPath: ["presentation_submission"], className: AuthorizationResponse.className)
    //        }
    //
    //        var bodyComponents = [URLQueryItem]()
    //        bodyComponents.append(URLQueryItem(name: "vp_token", value: encodeQueryValue(encodedVPTokenData)))
    //        bodyComponents.append(URLQueryItem(name: "presentation_submission", value: encodeQueryValue(encodedPresentationSubmissionData)))
    //        bodyComponents.append(URLQueryItem(name: "state", value: encodeQueryValue(state)))
    //
    //        var urlComponents = URLComponents()
    //        urlComponents.queryItems = bodyComponents
    //
    //        let requestBody = urlComponents.query
    //
    //        guard let url = URL(string: responseUri) else {
    //            throw Logger.handleException(exceptionType: "UrlCreationFailed", fieldPath: ["response_uri"], className: AuthorizationResponse.className)
    //        }
    //
    //        return try await networkManager.sendHTTPRequest(url: url, method: HTTP_METHOD.POST, bodyParams: requestBody ?? "", headers: ["Content-Type" : "application/x-www-form-urlencoded"])
    //    }
    
}
