import SwiftUI

public final class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()
    
    @Published public var isDarkMode: Bool = true
    
    private init() {}
}
