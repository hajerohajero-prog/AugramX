import Foundation
import Combine
import Core
import SwiftUI

@MainActor
public class ChatDetailViewModel: ObservableObject {
    public let chat: Chat
    public let telegramService: TelegramServiceProtocol
    
    @Published public var messages: [Message] = []
    @Published public var isLoading = true
    @Published public var messageText: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(chat: Chat, telegramService: TelegramServiceProtocol) {
        self.chat = chat
        self.telegramService = telegramService
        
        setupBindings()
    }
    
    private func setupBindings() {
        telegramService.newMessages
            .filter { $0.chatId == self.chat.id }
            .receive(on: RunLoop.main)
            .sink { [weak self] newMessage in
                guard let self = self else { return }
                if !self.messages.contains(where: { $0.id == newMessage.id }) {
                    withAnimation(.spring()) {
                        self.messages.append(newMessage)
                        self.messages.sort(by: { $0.date < $1.date })
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    public func loadMessages() {
        isLoading = true
        telegramService.getChatHistory(chatId: chat.id, fromMessageId: 0, limit: 50)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
        }
    }
    
    public func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        telegramService.sendMessage(chatId: chat.id, text: text)
        messageText = ""
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
