import SwiftUI

public struct GlassSurface<Content: View>: View {
    public var cornerRadius: CGFloat
    public var material: Material
    public var strokeColor: Color
    public var content: () -> Content

    public init(
        cornerRadius: CGFloat = DesignTokens.cornerRadius,
        material: Material = .regular,
        strokeColor: Color = Color.white.opacity(0.15),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.material = material
        self.strokeColor = strokeColor
        self.content = content
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(material)
            
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(strokeColor, lineWidth: 0.5)
            
            content()
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
