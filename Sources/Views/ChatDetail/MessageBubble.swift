import SwiftUI
import Design
import Core

public struct MessageBubble: View {
    public let message: Message
    
    public init(message: Message) {
        self.message = message
    }
    
    public var text: String {
        if case let .text(t) = message.content { return t }
        return "Unsupported Message"
    }
    
    public var body: some View {
        HStack {
            if message.isOutgoing { Spacer() }
            
            VStack(alignment: message.isOutgoing ? .trailing : .leading, spacing: 4) {
                Text(text)
                    .font(DesignTokens.body)
                    .foregroundColor(message.isOutgoing ? .white : DesignTokens.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Group {
                            if message.isOutgoing {
                                DesignTokens.accentGradient
                            } else {
                                GlassSurface(cornerRadius: 18, material: .thick, strokeColor: Color.white.opacity(0.1)) {
                                    Color.clear
                                }
                            }
                        }
                    )
                    .clipShape(RoundedCornerShape(radius: 18, corners: message.isOutgoing ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight]))
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Timestamp & read receipt
                HStack(spacing: 4) {
                    Text(formatDate(message.date))
                        .font(.system(size: 11))
                        .foregroundColor(DesignTokens.secondary)
                    
                    if message.isOutgoing {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(DesignTokens.accent)
                    }
                }
                .padding(message.isOutgoing ? .trailing : .leading, 4)
            }
            
            if !message.isOutgoing { Spacer() }
        }
        .padding(.horizontal, DesignTokens.spacingM)
        .padding(.vertical, 2)
        .transition(.asymmetric(insertion: .scale(scale: 0.9).combined(with: .opacity), removal: .opacity))
    }
    
    private func formatDate(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

public struct RoundedCornerShape: Shape {
    public var radius: CGFloat
    public var corners: UIRectCorner

    public init(radius: CGFloat, corners: UIRectCorner) {
        self.radius = radius
        self.corners = corners
    }

    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
