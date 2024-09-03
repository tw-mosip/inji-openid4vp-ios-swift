import Foundation

struct AuthorizationResponse{
    static var vpTokenForSigning: VpTokenForSigning?
    static var descriptorMap: [DescriptorMap]?
    
    static func constructVpForSigning(_ credentialsMap: [String: [String]]) throws -> String {
        
        Logger.getLogTag(className: String(describing: self))
        
        var credentialsArray: [String] = []
        var descriptorsMap: [DescriptorMap] = []
        var path: Int = 0
        
        guard !credentialsMap.isEmpty else {
            Logger.error("Credential map is empty.")
            throw AuthorizationResponseException.credentialsMapIsEmpty
        }
        
        for (key,values) in credentialsMap {
            if values.isEmpty {
                Logger.error("Value is empty for \(key) in credentialsMap.")
                throw AuthorizationResponseException.credentialsMapValueIsEmpty
            }
            for vc in values {
                credentialsArray.append(vc)
                descriptorsMap.append(DescriptorMap(id: key, format: .ldp_vc, path: "$.verifiableCredential[\(path)]"))
                path += 1
            }
        }
        
        self.descriptorMap = descriptorsMap
        self.vpTokenForSigning = VpTokenForSigning(verifiableCredential: credentialsArray, holder: "")
        
        do {
           return try encodeToJsonString(self.vpTokenForSigning)!
        } catch {
            Logger.error("VpToken generation for signing failed.")
            throw AuthorizationResponseException.jsonEncodingException(fieldName: "vpTokenForSigning")
        }
    }
    
    static func shareVp(vpResponseMetadata: VPResponseMetadata, nonce: String, responseUri: String, presentationDefinitionId: String, networkManager: NetworkManaging) async throws -> String? {
        
        try vpResponseMetadata.validate()
        
        let proof = Proof.constructProof(from: vpResponseMetadata, challenge: nonce)
        
        let presentationSubmission = PresentationSubmission(definition_id: presentationDefinitionId, descriptor_map: self.descriptorMap!)
        
        let vpToken = VpToken.constructVpToken(signingVPToken: vpTokenForSigning!, proof: proof)
        
        return try await constructHttpRequestBody(vpToken: vpToken, presentationSubmission: presentationSubmission, responseUri: responseUri, networkManager: networkManager)
    }
    
    private static func constructHttpRequestBody(vpToken: VpToken, presentationSubmission: PresentationSubmission, responseUri: String, networkManager: NetworkManaging = NetworkManager.shared) async throws -> String? {
        
        guard let encodedVPTokenData = try? encodeToJsonString(vpToken) else {
            Logger.error("Vp token encoding failed.")
            throw AuthorizationResponseException.jsonEncodingException(fieldName: "vpToken")
        }
        
        guard let encodedPresentationSubmissionData = try? encodeToJsonString(presentationSubmission) else {
            Logger.error("Presentation Submission encoding failed.")
            throw AuthorizationResponseException.jsonEncodingException(fieldName: "presentationSubmission")
        }
        
        let requestBody = """
        {
            "vp_token": \(encodedVPTokenData),
            "presentation_submission": \(encodedPresentationSubmissionData)
        }
        """
        
        guard let url = URL(string: responseUri) else {
            Logger.error("Invalid response uri.")
            throw AuthorizationResponseException.invalidURL
        }
        
        return try await networkManager.sendHTTPPostRequest(requestBody: requestBody, url: url)
    }
}
