import Foundation

class Logger {
    private static var logTag = ""
    private static var traceabilityId: String?
    
    static func getLogTag(className: String, traceabilityId: String? = nil) {
        if let traceId = traceabilityId {
            self.traceabilityId = traceId
        }
        logTag = "INJI-OpenID4Vp : \(className) | traceID \(self.traceabilityId ?? "")"
    }
    
    static func error(_ message: String) {
        print("\(logTag) | ERROR: \(message)")
    }
}
