import Foundation
@testable import OpenId4VP

class MockNetworkManager: NetworkManaging {
    var response: HTTPURLResponse?
    var error: Error?

    func sendHTTPPostRequest(requestBody: String, url: URL) async throws -> String? {
        if let error = error {
            throw error
        }
        return "Success: Request completed successfully."
    }
}
