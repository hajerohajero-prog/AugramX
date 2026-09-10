import SwiftUI
import Design

public struct ComposerView: View {
    @Binding public var text: String
    public var onSend: () -> Void
    
    public init(text: Binding<String>, onSend: @escaping () -> Void) {
        self._text = text
        self.onSend = onSend
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Divider().background(Color.white.opacity(0.1))
            
            HStack(alignment: .bottom, spacing: 12) {
                // Attach button
                Button(action: { DesignTokens.playHaptic() }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(DesignTokens.secondary)
                }
                .padding(.bottom, 8)
                
                // Input field
                GlassSurface(cornerRadius: 20, material: .ultraThin, strokeColor: Color.white.opacity(0.2)) {
                    TextField("Message...", text: $text, axis: .vertical)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .lineLimit(1...5)
                        .font(DesignTokens.body)
                }
                
                // Action buttons (Send or Mic)
                if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button(action: { DesignTokens.playHaptic() }) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 20))
                            .foregroundColor(DesignTokens.secondary)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.clear))
                    }
                    .padding(.bottom, 2)
                } else {
                    Button(action: {
                        onSend()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(DesignTokens.accent)
                    }
                    .padding(.bottom, 4)
                    .transition(.scale)
                }
            }
            .padding(.horizontal, DesignTokens.spacingM)
            .padding(.vertical, DesignTokens.spacingS)
            .background(DesignTokens.background.opacity(0.85))
        }
    }
}
