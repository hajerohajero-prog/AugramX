import Foundation

public final class IntegrityChecker {
    public static let shared = IntegrityChecker()
    private init() {}
    
    public func performLaunchChecks() -> Bool {
        #if DEBUG
        return true
        #else
        // Check for basic bundle integrity and embedded framework presence
        let bundlePath = Bundle.main.bundlePath
        let frameworksPath = (bundlePath as NSString).appendingPathComponent("Frameworks/TDLibFramework.xcframework")
        guard FileManager.default.fileExists(atPath: frameworksPath) else {
            return false
        }
        return true
        #endif
    }
}
