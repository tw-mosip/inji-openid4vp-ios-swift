import Foundation

public protocol NetworkManaging {
    func sendHTTPPostRequest(requestBody: String, url: URL) async throws -> HTTPURLResponse?
}

public struct NetworkManager: NetworkManaging {
    static var shared = NetworkManager()
    
    public func sendHTTPPostRequest(requestBody: String, url: URL) async throws -> HTTPURLResponse? {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody.data(using: .utf8)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                Logger.error("Invalid response received.")
                throw NetworkError.invalidResponse
            }
            
            return httpResponse
        } catch {
            Logger.error("Network request failed due to unknown error.")
            throw NetworkError.requestFailed(error)
        }
    }
}

enum NetworkError: Error {
    case invalidResponse
    case requestFailed(Error)
}
