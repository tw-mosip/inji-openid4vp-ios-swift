import Foundation

public struct AuthorizationResponse{
    static var vpToken: VpToken?
    static var descriptorMap: [DescriptorMap]?
    
    static func constructVpForSigning(_ credentialsMap: [String: [String]]) throws -> String {
        var credentialsArray: [String] = []
        var descriptorsMap: [DescriptorMap] = []
        var path: Int = 0
        
        guard !credentialsMap.isEmpty else {
            Logger.error("Credential map is empty.")
            throw AuthorizationResponseErrors.credentialsMapIsEmpty
        }
        
        for (key,values) in credentialsMap {
            if values.isEmpty {
                Logger.error("Value is empty for \(key) in credentialsMap.")
                throw AuthorizationResponseErrors.credentialsMapValueIsEmpty
            }
            for vc in values {
                credentialsArray.append(vc)
                descriptorsMap.append(DescriptorMap(id: key, format: format.ldp_vc, path: "$.verifiableCredential[\(path)]"))
                path += 1
            }
        }
        
        self.descriptorMap = descriptorsMap
        self.vpToken = VpToken(verifiableCredential: credentialsArray, holder: "")
        
        do {
           return try encodeToJsonString(self.vpToken)!
        } catch {
            Logger.error("VpToken generation for signing failed.")
            throw AuthorizationResponseErrors.vpTokenEnodingFailed
        }
    }
    
    static func shareVp(jws: String, signatureAlgoType: String, publicKey: String, domain: String, openId4VpInstance: OpenId4VP, networkManager: NetworkManaging) async throws -> HTTPURLResponse? {
        
        let proof = VpProof(type: signatureAlgoType, challenge: openId4VpInstance.authorizationRequest!.nonce, domain: "", jws: jws, proofPurpose: ProofPurpose.vpProofPurpose, verificationMethod: publicKey)
        
        let presentationSubmission = PresentationSubmission(definition_id: openId4VpInstance.presentationDefinitionId!, descriptor_map: self.descriptorMap!)
        
        self.vpToken?.proof = proof
        
        return try await constructHttpRequestBody(vpToken: vpToken!, presentationSubmission: presentationSubmission, responseUri: openId4VpInstance.authorizationRequest!.response_uri, networkManager: networkManager)
    }
    
    static func constructHttpRequestBody(vpToken: VpToken, presentationSubmission: PresentationSubmission, responseUri: String, networkManager: NetworkManaging = NetworkManager.shared) async throws -> HTTPURLResponse? {
        
        guard let encodedVPTokenData = try? encodeToJsonString(vpToken),
              let encodedPresentationSubmissionData = try? encodeToJsonString(presentationSubmission) else {
            Logger.error("Request body encoding failed.")
            throw AuthorizationResponseErrors.encodingToJsonStringFailed
        }
        
        let requestBody = """
        {
            "vp_token": \(encodedVPTokenData),
            "presentation_submission": \(encodedPresentationSubmissionData)
        }
        """
        
        guard let url = URL(string: responseUri) else {
            Logger.error("Invalid response uri.")
            throw AuthorizationResponseErrors.invalidURL
        }
        
        return try await networkManager.sendHTTPPostRequest(requestBody: requestBody, url: url)
    }
}
