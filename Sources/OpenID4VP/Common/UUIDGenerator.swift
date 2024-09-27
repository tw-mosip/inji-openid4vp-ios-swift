import Foundation

public struct UUIDGenerator{
   static func generateUUID() -> String {
        return UUID().uuidString.lowercased()
    }
}
