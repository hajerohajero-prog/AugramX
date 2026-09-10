import Foundation
import Combine

public enum TelegramAuthState: Equatable {
    case idle
    case waitingTdlibParameters
    case waitingEncryptionKey
    case waitingPhoneNumber
    case waitingCode
    case waitingPassword
    case waitingOtherDeviceConfirmation
    case waitingRegistration
    case waitingTermsOfService
    case ready
    case loggingOut
    case closing
    case closed
    case error(String)
}

public protocol TelegramServiceProtocol {
    var authState: AnyPublisher<TelegramAuthState, Never> { get }
    var isAuthorized: Bool { get }
    
    func initializeTDLib()
    func checkEncryptionKey()
    func sendPhoneNumber(_ phone: String)
    func sendAuthCode(_ code: String)
    func sendPassword(_ password: String)
    
    func fetchChatList(limit: Int)
    func getChatHistory(chatId: Int64, fromMessageId: Int64, limit: Int)
    func sendMessage(chatId: Int64, text: String)
    
    var newMessages: AnyPublisher<Message, Never> { get }
    var chatUpdates: AnyPublisher<Chat, Never> { get }
}

public final class TelegramService: TelegramServiceProtocol {
    private let bridge: TDLibBridgeProtocol
    private let authStateSubject = CurrentValueSubject<TelegramAuthState, Never>(.idle)
    private var isTdlibInitialized = false
    
    private let newMessagesSubject = PassthroughSubject<Message, Never>()
    private let chatUpdatesSubject = PassthroughSubject<Chat, Never>()
    
    public var authState: AnyPublisher<TelegramAuthState, Never> {
        authStateSubject.eraseToAnyPublisher()
    }
    
    public var newMessages: AnyPublisher<Message, Never> {
        newMessagesSubject.eraseToAnyPublisher()
    }
    
    public var chatUpdates: AnyPublisher<Chat, Never> {
        chatUpdatesSubject.eraseToAnyPublisher()
    }
    
    public var isAuthorized: Bool {
        if case .ready = authStateSubject.value { return true }
        return false
    }
    
    public init(bridge: TDLibBridgeProtocol) {
        self.bridge = bridge
        listenToUpdates()
    }
    
    private func listenToUpdates() {
        Task {
            for await data in bridge.updatesStream {
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let type = jsonObject["@type"] as? String else {
                    continue
                }
                
                switch type {
                case "updateAuthorizationState":
                    handleAuthorizationStateUpdate(jsonObject)
                    
                case "updateNewMessage":
                    if let messageDict = jsonObject["message"] as? [String: Any],
                       let messageData = try? JSONSerialization.data(withJSONObject: messageDict),
                       let message = try? JSONDecoder().decode(Message.self, from: messageData) {
                        newMessagesSubject.send(message)
                    }
                    
                case "messages":
                    if let messagesArray = jsonObject["messages"] as? [[String: Any]] {
                        for messageDict in messagesArray {
                            if let messageData = try? JSONSerialization.data(withJSONObject: messageDict),
                               let message = try? JSONDecoder().decode(Message.self, from: messageData) {
                                newMessagesSubject.send(message)
                            }
                        }
                    }
                    
                case "updateNewChat":
                    if let chatDict = jsonObject["chat"] as? [String: Any],
                       let chatData = try? JSONSerialization.data(withJSONObject: chatDict),
                       let chat = try? JSONDecoder().decode(Chat.self, from: chatData) {
                        chatUpdatesSubject.send(chat)
                    }
                    
                case "chats":
                    if let chatIds = jsonObject["chat_ids"] as? [Int64] {
                        for id in chatIds {
                            chatUpdatesSubject.send(Chat(id: id, title: "Chat \(id)"))
                        }
                    }
                    
                case "error":
                    if let code = jsonObject["code"] as? Int,
                       let message = jsonObject["message"] as? String {
                        authStateSubject.send(.error("TDLib Error \(code): \(message)"))
                    }
                    
                default:
                    break
                }
            }
        }
    }
    
    private func handleAuthorizationStateUpdate(_ jsonObject: [String: Any]) {
        guard let stateDict = jsonObject["authorization_state"] as? [String: Any],
              let stateType = stateDict["@type"] as? String else { return }
        
        switch stateType {
        case "authorizationStateWaitTdlibParameters":
            authStateSubject.send(.waitingTdlibParameters)
            initializeTDLib()
        case "authorizationStateWaitEncryptionKey":
            authStateSubject.send(.waitingEncryptionKey)
            checkEncryptionKey()
        case "authorizationStateWaitPhoneNumber":
            authStateSubject.send(.waitingPhoneNumber)
        case "authorizationStateWaitCode":
            authStateSubject.send(.waitingCode)
        case "authorizationStateWaitPassword":
            authStateSubject.send(.waitingPassword)
        case "authorizationStateWaitOtherDeviceConfirmation":
            authStateSubject.send(.waitingOtherDeviceConfirmation)
        case "authorizationStateWaitRegistration":
            authStateSubject.send(.waitingRegistration)
        case "authorizationStateWaitTermsOfService":
            authStateSubject.send(.waitingTermsOfService)
        case "authorizationStateReady":
            authStateSubject.send(.ready)
        case "authorizationStateLoggingOut":
            authStateSubject.send(.loggingOut)
        case "authorizationStateClosing":
            authStateSubject.send(.closing)
        case "authorizationStateClosed":
            authStateSubject.send(.closed)
        default:
            break
        }
    }
    
    public func initializeTDLib() {
        guard !isTdlibInitialized else { return }
        isTdlibInitialized = true
        
        var apiId: Int = 0
        if let idInt = Bundle.main.object(forInfoDictionaryKey: "API_ID") as? Int {
            apiId = idInt
        } else if let idStr = Bundle.main.object(forInfoDictionaryKey: "API_ID") as? String, let parsed = Int(idStr.trimmingCharacters(in: .whitespacesAndNewlines)) {
            apiId = parsed
        }
        
        var apiHash = (Bundle.main.object(forInfoDictionaryKey: "API_HASH") as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if apiId == 0 {
            apiId = 39657451
        }
        if apiHash.isEmpty {
            apiHash = "5ae054c81e95b258c17bac756c2f0b86"
        }
        
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let tdlibFolder = paths[0].appendingPathComponent("tdlib", isDirectory: true)
        
        try? FileManager.default.createDirectory(at: tdlibFolder, withIntermediateDirectories: true, attributes: nil)
        
        let req = SetTdlibParametersRequest(
            databaseDirectory: tdlibFolder.path,
            filesDirectory: tdlibFolder.path,
            apiId: apiId,
            apiHash: apiHash
        )
        bridge.send(request: req)
    }
    
    public func checkEncryptionKey() {
        let req = CheckDatabaseEncryptionKeyRequest()
        bridge.send(request: req)
    }
    
    public func sendPhoneNumber(_ phone: String) {
        let req = SetAuthenticationPhoneNumberRequest(phoneNumber: phone)
        bridge.send(request: req)
    }
    
    public func sendAuthCode(_ code: String) {
        let req = CheckAuthenticationCodeRequest(code: code)
        bridge.send(request: req)
    }
    
    public func sendPassword(_ password: String) {
        let req = CheckAuthenticationPasswordRequest(password: password)
        bridge.send(request: req)
    }
    
    public func fetchChatList(limit: Int) {
        let req = GetChatsRequest(limit: limit)
        bridge.send(request: req)
    }
    
    public func getChatHistory(chatId: Int64, fromMessageId: Int64, limit: Int) {
        let req = GetChatHistoryRequest(chatId: chatId, fromMessageId: fromMessageId, offset: 0, limit: limit)
        bridge.send(request: req)
    }
    
    public func sendMessage(chatId: Int64, text: String) {
        let content = InputMessageContent(text: FormattedText(text: text))
        let req = SendMessageRequest(chatId: chatId, inputMessageContent: content)
        bridge.send(request: req)
    }
}
