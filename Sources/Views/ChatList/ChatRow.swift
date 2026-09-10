import SwiftUI
import Design
import Core

public struct ChatRow: View {
    public let chat: Chat
    public var unreadCount: Int
    public var lastMessage: String
    public var timeString: String
    
    public init(chat: Chat, unreadCount: Int = 0, lastMessage: String = "", timeString: String = "") {
        self.chat = chat
        self.unreadCount = unreadCount
        self.lastMessage = lastMessage.isEmpty ? "Telegram message" : lastMessage
        self.timeString = timeString.isEmpty ? "now" : timeString
    }
    
    public var body: some View {
        HStack(spacing: DesignTokens.spacingM) {
            // Avatar
            Circle()
                .fill(LinearGradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 56, height: 56)
                .overlay(Text(String(chat.title.prefix(1))).font(DesignTokens.title).foregroundColor(.white))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.title)
                        .font(DesignTokens.headline)
                        .foregroundColor(DesignTokens.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(timeString)
                        .font(DesignTokens.caption)
                        .foregroundColor(DesignTokens.secondary)
                }
                
                HStack {
                    Text(lastMessage)
                        .font(DesignTokens.body)
                        .foregroundColor(DesignTokens.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    if unreadCount > 0 {
                        Text("\(unreadCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(DesignTokens.accent)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, DesignTokens.spacingM)
        .background(Color.clear)
        .contentShape(Rectangle())
    }
}
