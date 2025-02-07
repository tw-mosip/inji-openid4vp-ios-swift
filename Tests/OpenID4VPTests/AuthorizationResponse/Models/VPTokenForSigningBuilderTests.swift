import XCTest
@testable import OpenID4VP

class VPTokenForSigningBuilderTests : XCTestCase {
    
    func testCreationOfVPTokenForSigningForTheSelectedCredentials() throws{
        let credentialsMap: [String: Array<[String: Array<Any>]>] = [
                    "bank_input": [
                        ["ldp_vc": ["VC1"]],
                    ]
                ]
        
        
        let vpTokensForSigning = CheckNoThrow(try CredentialFormatSpecificSigningDataMapCreator.create(selectedCredentials: credentialsMap))!

        XCTAssertNotNil(vpTokensForSigning)
    }
    
    func testThrowNotSupportedFormatExeceptionWhenResponseCreationOfCredentialFormatIsNotSupported() {
        let credentialsMap: [String: Array<[String: Array<Any>]>] = [
                    "bank_input": [
                        ["mso_mdoc": ["VC1"]],
                    ]
                ]
        
        XCTAssertThrowsError(try CredentialFormatSpecificSigningDataMapCreator.create(selectedCredentials: credentialsMap)) { error in
            XCTAssertEqual(error as! AuthorizationResponseException, AuthorizationResponseException.unsupportedFormatOfLibrary)
        }

    }
}

