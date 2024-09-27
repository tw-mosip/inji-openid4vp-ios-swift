import Foundation

func encodeToJsonString<T: Encodable>(_ value: T) throws -> String? {
    let encoder = JSONEncoder()
    let jsonData = try encoder.encode(value)
    return String(data: jsonData, encoding: .utf8)
}
