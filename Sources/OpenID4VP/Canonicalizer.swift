import JavaScriptCore

public class Canonicalizer {
    private let context: JSContext

    public init?() {
        guard let ctx = JSContext() else { return nil }
        self.context = ctx

        guard let url = Bundle.module.url(forResource: "canonicalizer", withExtension: "js"),
              let script = try? String(contentsOf: url) else {
            print("Could not load canonicalizer.js")
            return nil
        }

        self.context.evaluateScript(script)
    }

    public func canonicalize(json: Any) -> String? {
        guard let canonicalizeFunc = context.objectForKeyedSubscript("canonicalize") else {
            print("Canonicalize function not found")
            return nil
        }

        let jsValue = JSValue(object: json, in: context)
        return canonicalizeFunc.call(withArguments: [jsValue!])?.toString()
    }
}
