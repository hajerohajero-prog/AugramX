import Foundation

public final class AppAttestService {
    public static let shared = AppAttestService()
    private init() {}
    
    public func isSupported() -> Bool {
        // AppAttest is supported on iOS 14+ on physical devices with Secure Enclave
        #if targetEnvironment(simulator)
        return false
        #else
        return true
        #endif
    }
    
    public func generateKey() async throws -> String {
        // Abstraction layer for DCAppAttestService
        return "app_attest_key_id_placeholder"
    }
}
