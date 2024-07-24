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
    
    let testVerifierList = "[{\"client_id\":\"https://injiverify.dev2.mosip.net\",\"redirect_uri\":[\"https://injiverify.qa-inji.mosip.net/redirect\",\"https://injiverify.dev2.mosip.net/redirect\"]},{\"client_id\":\"https://injiverify.dev1.mosip.net\",\"redirect_uri\":[\"https://injiverify.qa-inji.mosip.net/redirect\",\"https://injiverify.dev1.mosip.net/redirect\"]}]"
    
    let testValidPresentationDefinition = "{\"id\":\"2345333\",\"input_descriptors\":[{\"id\":\"banking_input_1\",\"name\":\"Bank Account Information\",\"purpose\":\"We can only remit payment to a currently-valid bank account in the US, France, or Germany, submitted as an ABA Acct or IBAN.\",\"constraints\":{\"fields\":[{\"path\":[\"$.crede\"],\"purpose\":\"We can use for  # verification purpose # for anything\",\"filter\":{\"type\":\"string\",\"pattern\":\"^[0-9]{9}|^([a-zA-Z]){4}([a-zA-Z]){2}([0-9a-zA-Z]){2}([0-9a-zA-Z]{3})?$\"}},{\"path\":[\"$.vc.credential\",\"$.vc.credentialSubject.account[*].route\",\"$.account[*].route\"],\"purpose\":\"We can use for verification purpose\",\"filter\":{\"type\":\"string\",\"pattern\":\"^[0-9]{9}|^([a-zA-Z]){4}([a-zA-Z]){2}([0-9a-zA-Z]){2}([0-9a-zA-Z]{3})?$\"}}]}}]}"
    
    let testValidEncodedVpRequest = "T1BFTklENFZQOi8vYXV0aG9yaXplP2NsaWVudF9pZD1odHRwcyUzQSUyRiUyRmluaml2ZXJpZnkuZGV2Mi5tb3NpcC5uZXQmcHJlc2VudGF0aW9uX2RlZmluaXRpb249eyJpZCI6IjIzNDUzMzMiLCJpbnB1dF9kZXNjcmlwdG9ycyI6W3siaWQiOiJiYW5raW5nX2lucHV0XzEiLCJuYW1lIjoiQmFuayBBY2NvdW50IEluZm9ybWF0aW9uIiwicHVycG9zZSI6IldlIGNhbiBvbmx5IHJlbWl0IHBheW1lbnQgdG8gYSBjdXJyZW50bHktdmFsaWQgYmFuayBhY2NvdW50IGluIHRoZSBVUywgRnJhbmNlLCBvciBHZXJtYW55LCBzdWJtaXR0ZWQgYXMgYW4gQUJBIEFjY3Qgb3IgSUJBTi4iLCJjb25zdHJhaW50cyI6eyJmaWVsZHMiOlt7InBhdGgiOlsiJC5jcmVkZSJdLCJwdXJwb3NlIjoiV2UgY2FuIHVzZSBmb3IgICMgdmVyaWZpY2F0aW9uIHB1cnBvc2UgIyBmb3IgYW55dGhpbmciLCJmaWx0ZXIiOnsidHlwZSI6InN0cmluZyIsInBhdHRlcm4iOiJeWzAtOV17OX18XihbYS16QS1aXSl7NH0oW2EtekEtWl0pezJ9KFswLTlhLXpBLVpdKXsyfShbMC05YS16QS1aXXszfSk/JCJ9fSx7InBhdGgiOlsiJC52Yy5jcmVkZW50aWFsIiwiJC52Yy5jcmVkZW50aWFsU3ViamVjdC5hY2NvdW50WypdLnJvdXRlIiwiJC5hY2NvdW50WypdLnJvdXRlIl0sInB1cnBvc2UiOiJXZSBjYW4gdXNlIGZvciB2ZXJpZmljYXRpb24gcHVycG9zZSIsImZpbHRlciI6eyJ0eXBlIjoic3RyaW5nIiwicGF0dGVybiI6Il5bMC05XXs5fXxeKFthLXpBLVpdKXs0fShbYS16QS1aXSl7Mn0oWzAtOWEtekEtWl0pezJ9KFswLTlhLXpBLVpdezN9KT8kIn19XX19XX0mcmVzcG9uc2VfdHlwZT12cF90b2tlbiZyZXNwb25zZV9tb2RlPWRpcmVjdF9wb3N0Jm5vbmNlPVZiUlJCL0xUeExpWG1WTlp1eU1POEE9PSZzdGF0ZT0rbVJRZTFkNnBCb0pxRjZBYjI4a2xnPT0mcmVzcG9uc2VfdXJpPS92ZXJpZmllci92cC1yZXNwb25zZSBIVFRQLzEuMQ=="
    
    let testInvalidEncodedVpRequest = "T1BFTklENFZQOi8vYXV0aG9yaXplP2NsaWVudF9pZD1odHRwcyUzQSUyRiUyRmluaml2ZXJpZnkuZGV2Mi5tb3NpcC5uZXQmcHJlc2VudGF0aW9uX2RlZmluaXRpb249eyJpZCI6IiIsImlucHV0X2Rlc2NyaXB0b3JzIjpbXX0mcmVzcG9uc2VfdHlwZT12cF90b2tlbiZyZXNwb25zZV9tb2RlPWRpcmVjdF9wb3N0Jm5vbmNlPVZiUlJCL0xUeExpWG1WTlp1eU1POEE9PSZzdGF0ZT0rbVJRZTFkNnBCb0pxRjZBYjI4a2xnPT0mcmVzcG9uc2VfdXJpPS92ZXJpZmllci92cC1yZXNwb25zZSBIVFRQLzEuMQ=="
    
    func areDictionariesEqual(_ dict1: [String: Any], _ dict2: [String: Any]) -> Bool {
        let sortedJson1 = sortedJsonString(from: dict1)
        let sortedJson2 = sortedJsonString(from: dict2)
        return sortedJson1 == sortedJson2
    }
    
    func sortedJsonString(from dictionary: [String: Any]) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [.sortedKeys]),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    func areArraysOfDictionariesEqual(_ array1: [[String: Any]], _ array2: [[String: Any]]) -> Bool {
        guard array1.count == array2.count else { return false }
        
        for (index, dict1) in array1.enumerated() {
            let dict2 = array2[index]
            if !areDictionariesEqual(dict1, dict2) {
                return false
            }
        }
        return true
    }
    
    func testReturnDataForValidRequest() {
        
        let expectedResult: [String: Any] = [PresentationDefinitionParams.clientid: "https://injiverify.dev2.mosip.net",PresentationDefinitionParams.presentationdefinition: testValidPresentationDefinition]
        
        let decodedString: [String: Any]?
        do {
            decodedString = try openId4Vp.authenticateVerifier(encodedAuthenticationRequest: testValidEncodedVpRequest, trustedVerifierJSON: testVerifierList)
        } catch {
            decodedString = nil
        }
        
        XCTAssertTrue(areDictionariesEqual(expectedResult, decodedString!), "The expected and decoded results do not match. Expected: \(expectedResult), Received: \(String(describing: decodedString))")
    }
    
    func testReturnErrorListForInvalidRequest() {
        
        let errors = ["Id must not be empty.","Input descriptors must not be empty."]
        
        let expectedResult: [String : Any] = [PresentationDefinitionParams.clientid: "https://injiverify.dev2.mosip.net",PresentationDefinitionError.PresentationDefinitionErrors: errors]
        
        let decodedString: [String: Any]?
        do {
            decodedString = try openId4Vp.authenticateVerifier(encodedAuthenticationRequest: testInvalidEncodedVpRequest, trustedVerifierJSON: testVerifierList)
        } catch {
            decodedString = nil
        }
        XCTAssertTrue(areDictionariesEqual(expectedResult, decodedString!), "The expected and decoded results do not match. Expected: \(expectedResult), Received: \(String(describing: decodedString))")
    }
    
    func testInvalidPresentationDefinitionJson() {
        let invalidJson = "Invalid JSON"
        XCTAssertThrowsError(try validatePresentationDefinition(presentatioDefinition: invalidJson)) { error in
            XCTAssertEqual(error as? AuthorizationRequestErrors, AuthorizationRequestErrors.presentationDefinitionValidationFailed)
        }
    }
    
    func testMissingFieldIdPresentationDefinition() {
        
        let expected = ["Id should be present","InputDescriptor 1: Id should be present"]
        let invalidJson = "{\"input_descriptors\":[{\"constraints\":{\"fields\":[{\"path\":[\"$.credentialSubject.account[*].id\"],\"filter\":{\"type\":\"string\",\"pattern\":\"^$\"}},{\"path\":[\"$.credentialSubject.account[*].route\"],\"filter\":{\"type\":\"string\",\"pattern\":\"^$\"}}]}}]}"
        
        var result: [String] = []
        do{
            result = try validatePresentationDefinition(presentatioDefinition: invalidJson)!
        }catch{
            XCTAssertTrue(expected.elementsEqual(result))
        }
    }
    
    func testParseVerifiersList(){
        let expectedResult: [[String: Any]] = [
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
        
        do {
            let result = try parseTrustedVerifiers(trustedVerifierJSON: testVerifierList)
            XCTAssertTrue(areArraysOfDictionariesEqual(result!, expectedResult), "The parsed result does not match the expected result.")
        } catch {
            XCTFail("The function threw an error: \(error)")
        }
    }
}
