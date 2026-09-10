import Foundation
import Combine
import Core
import SwiftUI

@MainActor
public class ChatListViewModel: ObservableObject {
    @Published public var chats: [Chat] = []
    @Published public var isLoading = true
    
    public let telegramService: TelegramServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    public init(telegramService: TelegramServiceProtocol) {
        self.telegramService = telegramService
        setupBindings()
    }
    
    private func setupBindings() {
        telegramService.chatUpdates
            .receive(on: RunLoop.main)
            .sink { [weak self] newChat in
                guard let self = self else { return }
                if !self.chats.contains(where: { $0.id == newChat.id }) {
                    withAnimation {
                        self.chats.append(newChat)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    public func loadChats() {
        isLoading = true
        telegramService.fetchChatList(limit: 50)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
        }
    }
}
