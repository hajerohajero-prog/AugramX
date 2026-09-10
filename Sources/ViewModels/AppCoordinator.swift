import SwiftUI
import Combine
import Core

public class AppCoordinator: ObservableObject {
    public enum Flow {
        case onboarding
        case auth
        case chatList
    }
    
    @Published public var flow: Flow = .onboarding
    public let telegramService: TelegramServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    public init(telegramService: TelegramServiceProtocol = TelegramService(bridge: TDLibBridge())) {
        self.telegramService = telegramService
        
        self.telegramService.authState
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                if case .ready = state {
                    self?.flow = .chatList
                }
            }
            .store(in: &cancellables)
    }
    
    public func startAuth() {
        flow = .auth
        telegramService.initializeTDLib()
    }
}
