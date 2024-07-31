//import Foundation
//
//class NetworkManager {
//    
//    static func sendResponse(url: String, header: String, method: String, payload: Encodable){
//        
//        let url = URL(string: url)!
//        var request = URLRequest(url: url)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "POST"
//        let encoder = JSONEncoder()
//        let data: Data
//        do {
//            let data = try encoder.encode(payload)
//            request.httpBody = data
//        } catch {
//            
//        }
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            // Handle the response here
//            if let error = error {
//                print("Error: \(error)")
//                return
//            }
//        
//    }
//}
