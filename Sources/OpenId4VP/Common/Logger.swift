import Foundation

class Logger {
    private static var logTag = ""
    private static var traceabilityId: String?
    
    static func setLogTag(className: String, traceabilityId: String? = nil) {
        if let traceId = traceabilityId {
            self.traceabilityId = traceId
        }
    }
    static func getLogTag(className: String) {
        logTag = "INJI-OpenID4Vp : \(className) | traceID \(String(describing: self.traceabilityId))"
    }
    
    static func error(_ message: String) {
        print("\(logTag) | ERROR: \(message)")
    }
}
