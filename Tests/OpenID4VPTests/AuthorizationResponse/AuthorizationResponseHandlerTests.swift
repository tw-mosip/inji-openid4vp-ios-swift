import Foundation
import XCTest
@testable import OpenID4VP

class AuthorizationResponseHandlerTests: XCTestCase {
    let authorizationRequestWithVPTokenResponseTypeAndDirectPostResponseMode = AuthorizationRequest(
        clientId: "client_id",
        clientIdScheme: "123",
        presentationDefinition: "presentationDefinition" as String,
        responseType: "vp_token",
        responseMode: "direct_post",
        nonce: "nonce",
        state: "state",
        redirectUri: "1234",
        responseUri: "https://example.com",
        clientMetadata: "clientMetaData" as String
    )
    let vpResponseMetaData = [FormatType.ldp_vc:LdpVPResponseMetadata(jws: "wemcn3234ns", signatureAlgorithm: "RsaSignature2018", publicKey: "-----BEGIN PUBLIC KEY-----\\nMIIBIjANBggvSPv73S\\nG5ToTt07NZPdKDrg9lSjetZup39oj12u0YoyRMlMhY0xYL6c8X1BexM7Wlp+c13o\\n1QIDAQAB\\n-----END PUBLIC KEY-----\\n", domain: "https://example")]
    let credentialsMap: [String: Array<[String: Array<Any>]>] = [
        "bank_input": [
            ["ldp_vc": ["VC1"]],
        ]
    ]
    let vpTokensForSigning = [FormatType.ldp_vc: LdpVpSpecificSigningData(verifiableCredential: ["VC1"], holder: "wallet/app")]
    let mockNetworkManager = MockNetworkManager()
    let successAuthorizationResponse = AuthorizationResponse(vpToken: VPTokenType.vpToken( LdpVpToken(context: ["context"], type: ["VerifiableCredential"], verifiableCredential: ["VC1"], id: "id", holder: "holder", proof: Proof(type: "jwt", created: "currentTime", challenge: "verifier_nonce", domain: "verifier_domain", jws: "jws", proofPurpose: ProofPurpose.vpProofPurpose, verificationMethod: "public-key-resolving"))), presentation_submission: PresentationSubmission(
        definition_id: "client_id",
        descriptor_map: [
            DescriptorMap(
                id: "bank_input",
                format: FormatType.ldp_vc,
                path: "$[0]",
                path_nested: "$[0].verifiableCredential[0]"
            )
        ]
    ))
    
    func testCreateAuthorizationResponseSuccessfullyWhenResponseTypeIsVpToken() {
        let authorizationResponseHandler = AuthorizationResponseHandler(networkManager: mockNetworkManager)
        
        let authorizationResponse = try? authorizationResponseHandler.createAuthorizationReponse(authorizationRequest: authorizationRequestWithVPTokenResponseTypeAndDirectPostResponseMode, vpResponseMetadata: vpResponseMetaData, vpTokensForSigning: vpTokensForSigning, credentialsMap: credentialsMap)
        
        
        let expectedPresentationSubmission = PresentationSubmission(
            definition_id: "client_id",
            descriptor_map: [
                DescriptorMap(
                    id: "bank_input",
                    format: FormatType.ldp_vc,
                    path: "$[0]",
                    path_nested: "$[0].verifiableCredential[0]"
                )
            ]
        )
        XCTAssertTrue(((authorizationResponse?.presentation_submission.equals(expectedPresentationSubmission)) != nil))
        XCTAssertNotNil(authorizationResponse?.vpToken)
    }
    
    func testCreateAuthorizationResponseThrowErrorWhenResponseTypeIsNotSupportedByLibrary()  {
        let authorizationRequest = AuthorizationRequest(
            clientId: "client_id",
            clientIdScheme: "123",
            presentationDefinition: "presentationDefinition" as String,
            responseType: "code",
            responseMode: "responseMode",
            nonce: "nonce",
            state: "state",
            redirectUri: "1234",
            responseUri: "https://example.com",
            clientMetadata: "clientMetaData" as String
        )
        let authorizationResponseHandler = AuthorizationResponseHandler(networkManager: mockNetworkManager)
        
        XCTAssertThrowsError(try authorizationResponseHandler.createAuthorizationReponse(authorizationRequest: authorizationRequest, vpResponseMetadata: vpResponseMetaData, vpTokensForSigning: vpTokensForSigning, credentialsMap: credentialsMap)) { error in
            XCTAssertEqual(error as! AuthorizationResponseException, AuthorizationResponseException.unsupportedResponseType)
        }
    }
    
    func testSendAuthorizationResponseToVerifierSuccessInResponseModeDirectPost() async {
        let authorizationResponseHandler = AuthorizationResponseHandler(networkManager: mockNetworkManager)
        
        
        try? await authorizationResponseHandler.sendAuthorizationResponseToVerifier(authorizationResponse: successAuthorizationResponse, authorizationRequest: authorizationRequestWithVPTokenResponseTypeAndDirectPostResponseMode)
        
        // Assert if call is made to response_uri
        XCTAssertTrue(mockNetworkManager.calledUrls.contains("https://example.com"))
    }
    
    func testSendAuthorizationResponseToVerifierThrowErrorWhenResponseModeIsNotSupportedByLibrary() async {
        let authorizationRequest = AuthorizationRequest(
            clientId: "client_id",
            clientIdScheme: "123",
            presentationDefinition: "presentationDefinition" as String,
            responseType: "vp_token",
            responseMode: "direct_post.jwt",
            nonce: "nonce",
            state: "state",
            redirectUri: "1234",
            responseUri: "https://example.com",
            clientMetadata: "clientMetaData" as String
        )
        let authorizationResponseHandler = AuthorizationResponseHandler(networkManager: mockNetworkManager)
        
        do {
            try await authorizationResponseHandler.sendAuthorizationResponseToVerifier(authorizationResponse: successAuthorizationResponse, authorizationRequest: authorizationRequest)
            XCTFail("It is expected to throw unsupported response mode error but error is not thrown when response mode is \(authorizationRequest.responseMode ?? "fragment")")
        }
        catch {
            XCTAssertEqual(error as! AuthorizationResponseException, AuthorizationResponseException.unsupportedResponseMode)
        }
    }
}

extension PresentationSubmission {
    func equals(_ other: PresentationSubmission) -> Bool {
        return self.definition_id == other.definition_id && self.descriptor_map.elementsEqual(other.descriptor_map, by: {$0.equals($1)})
    }
}

extension DescriptorMap {
    func equals(_ other: DescriptorMap) -> Bool {
        return self.format == other.format && self.path == other.path && self.path_nested == other.path_nested
    }
}

