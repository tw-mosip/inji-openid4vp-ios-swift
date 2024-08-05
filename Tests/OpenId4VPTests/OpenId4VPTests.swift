import XCTest
@testable import OpenId4VP

class OpenId4VPTests: XCTestCase {
    var openId4Vp: OpenId4VP!
    var mockNetworkManager: MockNetworkManager!
    
    let authorizationRequest = AuthorizationRequest(
        clientId: "client_id",
        presentation_definition: "presentationDefinition",
        scope: "scope",
        response_type: "responseType",
        response_mode: "responseMode",
        nonce: "nonce",
        state: "state",
        response_uri: "https://example.com"
    )
    
    override func setUp() {
        super.setUp()
        
        mockNetworkManager = MockNetworkManager()
        
        let descriptorMap: [DescriptorMap] = [
            DescriptorMap(id: "bank_input", format: "ldp_vc", path: "$.verifiableCredential[0]"),
            DescriptorMap(id: "bank_input", format: "ldp_vc", path: "$.verifiableCredential[1]")
        ]
        
        let vpToken = VpToken(verifiableCredential: ["VC1", "VC2"],holder: "")
        
        openId4Vp = OpenId4VP(traceabilityId: "AXESWSAW123")
        openId4Vp.presentationDefinitionId = "AWSE"
        
        AuthorizationResponse.descriptorMap = descriptorMap
        AuthorizationResponse.vpToken = vpToken
    }
    
    override func tearDown() {
        openId4Vp = nil
        mockNetworkManager = nil
        super.tearDown()
    }
    
    let testVerifierList:  [[String: Any]]  = [
        [
            "client_id": "https://injiverify.dev2.mosip.net",
            "redirect_uri": [
                "https://injiverify.qa-inji.mosip.net/redirect",
                "https://injiverify.dev2.mosip.net/redirect"
            ]
        ],
        [
            "client_id": "https://injiverify.dev1.mosip.net",
            "redirect_uri": [
                "https://injiverify.qa-inji.mosip.net/redirect",
                "https://injiverify.dev1.mosip.net/redirect"
            ]
        ]
    ]
    
    let testValidEncodedVpRequest = "T1BFTklENFZQOi8vYXV0aG9yaXplP2NsaWVudF9pZD1odHRwcyUzQSUyRiUyRmluaml2ZXJpZnkuZGV2Mi5tb3NpcC5uZXQmcHJlc2VudGF0aW9uX2RlZmluaXRpb249eyJpZCI6IjIzNDUzMzMiLCJpbnB1dF9kZXNjcmlwdG9ycyI6W3siaWQiOiJiYW5raW5nX2lucHV0XzEiLCJuYW1lIjoiQmFuayBBY2NvdW50IEluZm9ybWF0aW9uIiwicHVycG9zZSI6IldlIGNhbiBvbmx5IHJlbWl0IHBheW1lbnQgdG8gYSBjdXJyZW50bHktdmFsaWQgYmFuayBhY2NvdW50IGluIHRoZSBVUywgRnJhbmNlLCBvciBHZXJtYW55LCBzdWJtaXR0ZWQgYXMgYW4gQUJBIEFjY3Qgb3IgSUJBTi4iLCJjb25zdHJhaW50cyI6eyJmaWVsZHMiOlt7InBhdGgiOlsiJC5jcmVkZSJdLCJwdXJwb3NlIjoiV2UgY2FuIHVzZSBmb3IgICMgdmVyaWZpY2F0aW9uIHB1cnBvc2UgIyBmb3IgYW55dGhpbmciLCJmaWx0ZXIiOnsidHlwZSI6InN0cmluZyIsInBhdHRlcm4iOiJeWzAtOV17OX18XihbYS16QS1aXSl7NH0oW2EtekEtWl0pezJ9KFswLTlhLXpBLVpdKXsyfShbMC05YS16QS1aXXszfSk/JCJ9fSx7InBhdGgiOlsiJC52Yy5jcmVkZW50aWFsIiwiJC52Yy5jcmVkZW50aWFsU3ViamVjdC5hY2NvdW50WypdLnJvdXRlIiwiJC5hY2NvdW50WypdLnJvdXRlIl0sInB1cnBvc2UiOiJXZSBjYW4gdXNlIGZvciB2ZXJpZmljYXRpb24gcHVycG9zZSIsImZpbHRlciI6eyJ0eXBlIjoic3RyaW5nIiwicGF0dGVybiI6Il5bMC05XXs5fXxeKFthLXpBLVpdKXs0fShbYS16QS1aXSl7Mn0oWzAtOWEtekEtWl0pezJ9KFswLTlhLXpBLVpdezN9KT8kIn19XX19XX0mcmVzcG9uc2VfdHlwZT12cF90b2tlbiZyZXNwb25zZV9tb2RlPWRpcmVjdF9wb3N0Jm5vbmNlPVZiUlJCL0xUeExpWG1WTlp1eU1POEE9PSZzdGF0ZT0rbVJRZTFkNnBCb0pxRjZBYjI4a2xnPT0mcmVzcG9uc2VfdXJpPS92ZXJpZmllci92cC1yZXNwb25zZSBIVFRQLzEuMQ=="
    
    let testInvalidPresentationDefinitionVpRequest = "T1BFTklENFZQOi8vYXV0aG9yaXplP2NsaWVudF9pZD1odHRwcyUzQSUyRiUyRmluaml2ZXJpZnkuZGV2Mi5tb3NpcC5uZXQmcHJlc2VudGF0aW9uX2RlZmluaXRpb249eyJpbnB1dF9kZXNjcmlwdG9ycyI6W119JnJlc3BvbnNlX3R5cGU9dnBfdG9rZW4mcmVzcG9uc2VfbW9kZT1kaXJlY3RfcG9zdCZub25jZT1WYlJSQi9MVHhMaVhtVk5adXlNTzhBPT0mc3RhdGU9K21SUWUxZDZwQm9KcUY2QWIyOGtsZz09JnJlc3BvbnNlX3VyaT0vdmVyaWZpZXIvdnAtcmVzcG9uc2UgSFRUUC8xLjE="
    
    let invalidVpRequest = "T1BFTklENFZQOi8vYXV0aG9yaXplP2NsaWVudF9pZD1odHRwcyUzQSUyRiUyRmluaml2ZXJpZnkuZGV2Mi5tb3NpcC5uZXQmcmVzcG9uc2VfdHlwZT12cF90b2tlbiZyZXNwb25zZV9tb2RlPWRpcmVjdF9wb3N0Jm5vbmNlPVZiUlJCL0xUeExpWG1WTlp1eU1POEE9PSZzdGF0ZT0rbVJRZTFkNnBCb0pxRjZBYjI4a2xnPT0mcmVzcG9uc2VfdXJpPS92ZXJpZmllci92cC1yZXNwb25zZSBIVFRQLzEuMQ=="
    
    func testReturnDataForValidRequest() {
        
        let verifiers = createVerifiers(from: testVerifierList)
        
        let decoded: Any?
        
        do {
            decoded = try openId4Vp.authenticateVerifier(encodedAuthenticationRequest: testValidEncodedVpRequest, trustedVerifierJSON: verifiers)
        } catch {
            decoded = nil
        }
        XCTAssertTrue(decoded is AuthenticationResponse, "decodedResponse should not be an instance of AuthenticationResponse")
        XCTAssertTrue(decoded != nil, "decodedResponse should not be null")
    }
    
    func testMissingPresentationDefinitionFields() {
        
        let verifiers = createVerifiers(from: testVerifierList)
        
        XCTAssertThrowsError(try openId4Vp.authenticateVerifier(encodedAuthenticationRequest: testInvalidPresentationDefinitionVpRequest, trustedVerifierJSON: verifiers)) { error in
            XCTAssertEqual(error as? AuthenticationResponseErrors, AuthenticationResponseErrors.invalidPresentationDefinition)
        }
    }
    
    func testMissingRequiredFieldsInRequest() {
        
        let verifiers = createVerifiers(from: testVerifierList)
        
        XCTAssertThrowsError(try openId4Vp.authenticateVerifier(encodedAuthenticationRequest: invalidVpRequest, trustedVerifierJSON: verifiers)) { error in
            XCTAssertEqual(error as? AuthorizationRequestParseError, AuthorizationRequestParseError.invalidParameters)
        }
    }
    
    func testUUIDGeneration() {
        
        let vpToken = uuid.vpToken
        let presentationSubmissionId = uuid.presentationSubmissionId
        let presentationSubmission = PresentationSubmission(definition_id: "", descriptor_map: AuthorizationResponse.descriptorMap!)
        
        XCTAssertNotNil(vpToken,presentationSubmissionId)
        XCTAssertNotNil(presentationSubmission.id)
    }
    
    func testShareVerifiablePresentation(){
        let credentialsMap: [String: [String]] = ["bank_input":["VC1","VC2"]]
        let received: String?
        
        do {
            received = try openId4Vp.constructVerifiablePresentation(credentialsMap: credentialsMap)
        }catch{
            received = nil
        }
        XCTAssertNotNil(received,  "The response should not be nil for valid credentials map")
    }
    
    func testSendVpSuccess() async throws {
        let expectedResponse = HTTPURLResponse(url: URL(string: "https://example.com")!,
                                               statusCode: 200,
                                               httpVersion: nil,
                                               headerFields: nil)
        mockNetworkManager.response = expectedResponse

        openId4Vp.authorizationRequest = authorizationRequest

        let response = try await openId4Vp.sendVp(jws: "AXAX", signatureAlgoType: "Rsa", publicKey: "89jhh", domain: "", networkManager: mockNetworkManager)

        XCTAssertEqual(response?.statusCode, 200, "Expected status code to be 200")
    }
    
    func testSendVpFailure() async {
           mockNetworkManager.error = NetworkError.requestFailed(NSError(domain: "", code: 0, userInfo: nil))
           openId4Vp.authorizationRequest = authorizationRequest

           do {
               let _ = try await openId4Vp.sendVp(jws: "AXAX", signatureAlgoType: "Rsa", publicKey: "89jhh", domain: "", networkManager: mockNetworkManager)
           } catch {
               XCTAssertTrue(error is NetworkError, "Expected NetworkError")
           }
       }
}
