import Foundation
import XCTest
@testable import OpenID4VP

class AuthorizationRequestUtilTests: XCTestCase {
    let testVerifierList:  [[String: Any]]  = [
        [
            "client_id": "https://injiverify.dev2.mosip.net",
            "response_uris": [
                "https://injiverify.qa-inji.mosip.net/redirect",
                "https://injiverify.dev2.mosip.net/redirect"
            ]
        ],
        [
            "client_id": "https://injiverify.dev1.mosip.net",
            "response_uris": [
                "https://injiverify.qa-inji.mosip.net/redirect",
                "https://injiverify.dev1.mosip.net/redirect"
            ]
        ]
    ]
    let resquestUriResponseData: [String: Any] = [
        "client_id": "x509_san_dns:client.example.org",
        "response_uri": "https://injiverify.dev2.mosip.net",
        "presentation_definition": [
            "id": "123",
            "input_descriptors": [
                [
                    "id": "banking_input_1",
                    "format": [
                        "ldp_vc": [
                            "proof_type": ["Ed25519Signature2018"]
                        ]
                    ],
                    "name": "Bank Account Information",
                    "purpose": "hiiii",
                    "constraints": [
                        "fields": [
                            [
                                "path": ["$.crede"],
                                "purpose": "We can use for # verification purpose # for anything",
                                "filter": [
                                    "type": "string",
                                    "pattern": "^[0-9]{9}|^([a-zA-Z]){4}([a-zA-Z]){2}([0-9a-zA-Z]){2}([0-9a-zA-Z]{3})?$"
                                ]
                            ],
                            [
                                "path": ["$.vc.credential", "$.vc.credentialSubject.account[*].route", "$.account[*].route"],
                                "purpose": "We can use for verification purpose",
                                "filter": [
                                    "type": "string",
                                    "pattern": "^[0-9]{9}|^([a-zA-Z]){4}([a-zA-Z]){2}([0-9a-zA-Z]){2}([0-9a-zA-Z]{3})?$"
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ],
        "response_type": "vp_token",
        "response_mode": "direct_post",
        "nonce": "VbRRB/LTxLiXmVNZuyMO8A==",
        "state": "+mRQe1d6pBoJqF6Ab28klg==",
        "client_metadata": [
            "authorization_encrypted_response_alg": "ECDH-ES",
            "authorization_encrypted_response_enc": "A256GCM",
            "vp_formats": [
                "mso_mdoc": [
                    "alg": ["ES256", "EdDSA"]
                ],
                "ldp_vp": [
                    "proof_type": ["Ed25519Signature2018", "Ed25519Signature2020", "RsaSignature2018"]
                ]
            ]
        ]
    ]
    func testValidateVerifierThrowErrorWhenClientIdSchemeIsNotSupported() {
        let verifiers = createVerifiers(from: testVerifierList)
        
        XCTAssertThrowsError(try validateVerifier(verifierList: verifiers, params: resquestUriResponseData, shouldValidateClient: true)) { error in
            XCTAssertEqual(error.localizedDescription,"invalid_request: Wallet does not support the Client Identifier Scheme - x509_san_dns passed in the Authorization Request.")
        }
    }
    
    func testExtractClientIdPartOnlyWithDIDClientId(){
        let clientIdWithDidScheme = "did:example:123#1"

        let result = extractClientIdPartOnly(clientIdWithDidScheme)
        
        XCTAssertEqual(result, "did:example:123#1")
    }
    
    func testExtractClientIdPartOnlyWithRedirectUriClientId(){
        let clientIdWithRedirectUriScheme = "redirect_uri:https://client.example.org/cb"

        let result = extractClientIdPartOnly(clientIdWithRedirectUriScheme)
        
        XCTAssertEqual(result, "https://client.example.org/cb")
    }
    
    func testExtractClientIdPartOnlyWithPreRegisteredClientId(){
        let clientIdWithPreRegisteredSchemeWithSchemeMentioned = "pre-registered:example-client"
        let clientIdWithPreRegisteredSchemeWithoutSchemeMentioned = "example-client"

        let result1 = extractClientIdPartOnly(clientIdWithPreRegisteredSchemeWithSchemeMentioned)
        let result2 = extractClientIdPartOnly(clientIdWithPreRegisteredSchemeWithoutSchemeMentioned)
        
        XCTAssertEqual(result1, "example-client")
        XCTAssertEqual(result2, "example-client")
    }
}
