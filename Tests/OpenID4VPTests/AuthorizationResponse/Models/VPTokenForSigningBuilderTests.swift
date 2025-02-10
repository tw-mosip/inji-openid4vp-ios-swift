import XCTest
@testable import OpenID4VP

class VPTokenForSigningBuilderTests : XCTestCase {
    
    func testCreationOfVPTokenForSigningForTheSelectedCredentials() throws{
        let vpTokensForSigning = CheckNoThrow(try CredentialFormatSpecificSigningDataMapCreator.create(selectedCredentials: credentialsMap))!
        
        XCTAssertNotNil(vpTokensForSigning)
    }
    
    func testThrowNotSupportedFormatExeceptionWhenResponseCreationOfCredentialFormatIsNotSupported() {
        let credentialsMap: [String: [String: Array<Any>]] = [
            "bank_input":
                ["mso_mdoc": ["VC1"]],
            
        ]
        
        XCTAssertThrowsError(try CredentialFormatSpecificSigningDataMapCreator.create(selectedCredentials: credentialsMap)) { error in
            XCTAssertEqual(error as! AuthorizationResponseException, AuthorizationResponseException.unsupportedFormatOfLibrary)
        }
    }
}

