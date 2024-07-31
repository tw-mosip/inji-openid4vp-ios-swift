import XCTest
@testable import OpenId4VP

class OpenId4VPTests: XCTestCase {
    var openId4Vp: OpenId4VP!
    
    override func setUp() {
        super.setUp()
        openId4Vp = OpenId4VP(traceabilityId: "AXS")
    }
    
    override func tearDown() {
        openId4Vp = nil
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
    
    let testInvalidEncodedVpRequest = "T1BFTklENFZQOi8vYXV0aG9yaXplP2NsaWVudF9pZD1odHRwcyUzQSUyRiUyRmluaml2ZXJpZnkuZGV2Mi5tb3NpcC5uZXQmcHJlc2VudGF0aW9uX2RlZmluaXRpb249eyJpbnB1dF9kZXNjcmlwdG9ycyI6W119JnJlc3BvbnNlX3R5cGU9dnBfdG9rZW4mcmVzcG9uc2VfbW9kZT1kaXJlY3RfcG9zdCZub25jZT1WYlJSQi9MVHhMaVhtVk5adXlNTzhBPT0mc3RhdGU9K21SUWUxZDZwQm9KcUY2QWIyOGtsZz09JnJlc3BvbnNlX3VyaT0vdmVyaWZpZXIvdnAtcmVzcG9uc2UgSFRUUC8xLjE="
    
    func createVerifiers(from verifierList: [[String: Any]]) -> [[Verifier]] {
        var verifiers: [[Verifier]] = []
        
        for verifierData in verifierList {
            if let clientId = verifierData["client_id"] as? String,
               let redirectUri = verifierData["redirect_uri"] as? [String] {
                let verifier = Verifier(clientId: clientId, redirectUri: redirectUri)
                verifiers.append([verifier])
            }
        }
        
        return verifiers
    }
    
    func testReturnDataForValidRequest() {
        
        let verifiers = createVerifiers(from: testVerifierList)
        
        let decoded: AuthenticationResponse?
        
        do {
            decoded = try openId4Vp.authenticateVerifier(encodedAuthenticationRequest: testValidEncodedVpRequest, trustedVerifierJSON: verifiers)
        } catch {
            decoded = nil
        }
        
        XCTAssertTrue(decoded != nil, "decodedResponse should be an instance of AuthenticationResponse")
    }
    
    func testMissingPresentationDefinitionFields() {
        
        let verifiers = createVerifiers(from: testVerifierList)
        
        XCTAssertThrowsError(try openId4Vp.authenticateVerifier(encodedAuthenticationRequest: testInvalidEncodedVpRequest, trustedVerifierJSON: verifiers)) { error in
            XCTAssertEqual(error as? AuthorizationRequestErrors, AuthorizationRequestErrors.invalidPresentationDefinition)
        }
    }
    
    func testShareVerifiablePresentation(){
        let credentialsMap: [String: [String]] = ["bank_input":["VC1","VC2"],"employment_input": ["VC1","VC2"]]
        
        do {
            let response = try openId4Vp.constructVerifiablePresentation(credentialsMap: credentialsMap)
        }catch{
            
        }
       // print(response)
    }
}
