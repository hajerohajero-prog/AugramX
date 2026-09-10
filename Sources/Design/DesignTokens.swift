import SwiftUI

public struct DesignTokens {
    // MARK: - Colors (defined in Assets.xcassets)
    public static let background = Color("Background")
    public static let primary = Color("Primary")
    public static let secondary = Color("Secondary")
    public static let accent = Color("Accent")
    public static let blurMaterial = Color(.systemBackground).opacity(0.6)

    // MARK: - Typography
    public static let title = Font.system(size: 28, weight: .bold, design: .default)
    public static let headline = Font.system(size: 20, weight: .semibold, design: .default)
    public static let body = Font.system(size: 16, weight: .regular, design: .default)
    public static let caption = Font.system(size: 13, weight: .regular, design: .default)

    // MARK: - Spacing
    public static let spacingXS: CGFloat = 4
    public static let spacingS: CGFloat = 8
    public static let spacingM: CGFloat = 16
    public static let spacingL: CGFloat = 24

    // MARK: - Corners & Shadows
    public static let cornerRadius: CGFloat = 12
    public static let shadow = Shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)

    // MARK: - Animations
    public static let spring = Animation.interpolatingSpring(stiffness: 250, damping: 25)
    public static let easeInOut = Animation.easeInOut(duration: 0.2)
    
    // MARK: - Premium Materials
    public static let ultraThinMaterial = Material.ultraThin
    public static let thinMaterial = Material.thin
    public static let regularMaterial = Material.regular
    public static let thickMaterial = Material.thick
    
    // MARK: - Gradients
    public static let accentGradient = LinearGradient(
        gradient: Gradient(colors: [DesignTokens.accent, DesignTokens.accent.opacity(0.8)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Haptics
    public static func playHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

public struct Shadow {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat
    
    public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}
