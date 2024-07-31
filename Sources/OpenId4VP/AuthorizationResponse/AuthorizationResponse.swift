import Foundation

class AuthorizationResponse{
    let presentationSubmission: PresentationSubmission?
    let vpToken: VpToken?
    
    init(presentationSubmission: PresentationSubmission, vpToken: VpToken) {
        self.presentationSubmission = presentationSubmission
        self.vpToken = vpToken
    }
    
    static func constructResponse(_ pdid: String, descriptorMap: [String: [String]]) throws -> AuthorizationResponse {
        
        var mapDescriptors: [DescriptorMap] = []
        var credentialsArray: [String] = []
        var path: Int = 0
        
        for inputs in descriptorMap {
            for vc in inputs.value.enumerated() {
                credentialsArray.append(vc.element)
                mapDescriptors.append(DescriptorMap(id: inputs.key, format: "ldp_vc", path: "$.verifiableCredential[\(path)]"))
                path += 1
            }
        }
        let presentationSubmission = PresentationSubmission(definition_id: pdid, descriptor_map: mapDescriptors)
        
        let vpToken = VpToken(context: ["https://www.w3.org/2018/credentials/v1"], type: ["VerifiablePresentation"], verifiableCredential: credentialsArray, id: "", holder: "")
        
        let response = ""
        
        return AuthorizationResponse(presentationSubmission: presentationSubmission, vpToken: vpToken)
    }
}
