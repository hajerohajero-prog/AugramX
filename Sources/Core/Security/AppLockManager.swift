import Foundation
import Combine

public final class AppLockManager: ObservableObject {
    public static let shared = AppLockManager()
    @Published public var isLocked: Bool = false
    
    private init() {}
    
    public func lockApp() {
        isLocked = true
    }
    
    public func unlockApp() {
        isLocked = false
    }
}
