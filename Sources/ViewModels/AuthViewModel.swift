import Foundation
import Combine
import Core

public class AuthViewModel: ObservableObject {
    @Published public var phoneNumber: String = ""
    @Published public var code: String = ""
    @Published public var password: String = ""
    @Published public var errorMessage: String? = nil
    
    public let telegramService: TelegramServiceProtocol
    
    public init(telegramService: TelegramServiceProtocol) {
        self.telegramService = telegramService
    }
    
    public func submitPhone() {
        guard !phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        telegramService.sendPhoneNumber(phoneNumber)
    }
    
    public func submitCode() {
        guard !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        telegramService.sendAuthCode(code)
    }
    
    public func submitPassword() {
        guard !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        telegramService.sendPassword(password)
    }
}
