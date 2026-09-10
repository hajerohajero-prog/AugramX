import Foundation

// MARK: - TDLib Requests

struct SetTdlibParametersRequest: Encodable {
    let type = "setTdlibParameters"
    let useTestDc: Bool = false
    let databaseDirectory: String
    let filesDirectory: String
    let databaseEncryptionKey: String = ""
    let useFileDatabase: Bool = true
    let useChatInfoDatabase: Bool = true
    let useMessageDatabase: Bool = true
    let useSecretChats: Bool = false
    let apiId: Int
    let apiHash: String
    let systemLanguageCode: String = "en"
    let deviceModel: String = "iPhone"
    let systemVersion: String = "17.0"
    let applicationVersion: String = "1.0"
    let enableStorageOptimizer: Bool = true
    let ignoreFileNames: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case useTestDc = "use_test_dc"
        case databaseDirectory = "database_directory"
        case filesDirectory = "files_directory"
        case databaseEncryptionKey = "database_encryption_key"
        case useFileDatabase = "use_file_database"
        case useChatInfoDatabase = "use_chat_info_database"
        case useMessageDatabase = "use_message_database"
        case useSecretChats = "use_secret_chats"
        case apiId = "api_id"
        case apiHash = "api_hash"
        case systemLanguageCode = "system_language_code"
        case deviceModel = "device_model"
        case systemVersion = "system_version"
        case applicationVersion = "application_version"
        case enableStorageOptimizer = "enable_storage_optimizer"
        case ignoreFileNames = "ignore_file_names"
    }
}

struct CheckDatabaseEncryptionKeyRequest: Encodable {
    let type = "checkDatabaseEncryptionKey"
    let encryptionKey: String = ""
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case encryptionKey = "encryption_key"
    }
}

struct SetAuthenticationPhoneNumberRequest: Encodable {
    let type = "setAuthenticationPhoneNumber"
    let phoneNumber: String
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case phoneNumber = "phone_number"
    }
}

struct CheckAuthenticationCodeRequest: Encodable {
    let type = "checkAuthenticationCode"
    let code: String
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case code
    }
}

struct CheckAuthenticationPasswordRequest: Encodable {
    let type = "checkAuthenticationPassword"
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case password
    }
}

struct GetChatsRequest: Encodable {
    let type = "getChats"
    let chatList: ChatListFilter = ChatListFilter()
    let limit: Int
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case chatList = "chat_list"
        case limit
    }
}

struct ChatListFilter: Encodable {
    let type = "chatListMain"
    enum CodingKeys: String, CodingKey {
        case type = "@type"
    }
}

struct GetChatHistoryRequest: Encodable {
    let type = "getChatHistory"
    let chatId: Int64
    let fromMessageId: Int64
    let offset: Int
    let limit: Int
    let onlyLocal: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case chatId = "chat_id"
        case fromMessageId = "from_message_id"
        case offset
        case limit
        case onlyLocal = "only_local"
    }
}

struct SendMessageRequest: Encodable {
    let type = "sendMessage"
    let chatId: Int64
    let messageThreadId: Int64 = 0
    let replyToMessageId: Int64 = 0
    let options: SendMessageOptions? = nil
    let replyMarkup: String? = nil
    let inputMessageContent: InputMessageContent
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case chatId = "chat_id"
        case messageThreadId = "message_thread_id"
        case replyToMessageId = "reply_to_message_id"
        case options
        case replyMarkup = "reply_markup"
        case inputMessageContent = "input_message_content"
    }
}

struct SendMessageOptions: Encodable {
    let disableNotification: Bool = false
    let fromBackground: Bool = false
    let schedulingState: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case disableNotification = "disable_notification"
        case fromBackground = "from_background"
        case schedulingState = "scheduling_state"
    }
}

struct InputMessageContent: Encodable {
    let type = "inputMessageText"
    let text: FormattedText
    let disableWebPagePreview: Bool = false
    let clearDraft: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case text
        case disableWebPagePreview = "disable_web_page_preview"
        case clearDraft = "clear_draft"
    }
}

struct FormattedText: Encodable {
    let text: String
}

// MARK: - Core Domain & Response Models

public struct Chat: Identifiable, Decodable, Hashable {
    public let id: Int64
    public let title: String
    
    public init(id: Int64, title: String) {
        self.id = id
        self.title = title
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int64.self, forKey: .id)
        self.title = (try? container.decode(String.self, forKey: .title)) ?? "Chat \(id)"
    }
    
    public static func == (lhs: Chat, rhs: Chat) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct Message: Identifiable, Decodable, Equatable {
    public let id: Int64
    public let chatId: Int64
    public let senderId: MessageSender
    public let content: MessageContent
    public let date: Int
    public let isOutgoing: Bool
    public let isPinned: Bool
    
    public init(id: Int64, chatId: Int64, senderId: MessageSender, content: MessageContent, date: Int, isOutgoing: Bool, isPinned: Bool) {
        self.id = id
        self.chatId = chatId
        self.senderId = senderId
        self.content = content
        self.date = date
        self.isOutgoing = isOutgoing
        self.isPinned = isPinned
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case senderId = "sender_id"
        case content
        case date
        case isOutgoing = "is_outgoing"
        case isPinned = "is_pinned"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int64.self, forKey: .id)
        self.chatId = (try? container.decode(Int64.self, forKey: .chatId)) ?? 0
        self.senderId = (try? container.decode(MessageSender.self, forKey: .senderId)) ?? .unknown
        self.content = (try? container.decode(MessageContent.self, forKey: .content)) ?? .unsupported
        self.date = (try? container.decode(Int.self, forKey: .date)) ?? Int(Date().timeIntervalSince1970)
        self.isOutgoing = (try? container.decode(Bool.self, forKey: .isOutgoing)) ?? false
        self.isPinned = (try? container.decode(Bool.self, forKey: .isPinned)) ?? false
    }
    
    public static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}

public enum MessageSender: Decodable, Equatable {
    case user(Int64)
    case chat(Int64)
    case unknown
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case userId = "user_id"
        case chatId = "chat_id"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "messageSenderUser":
            let id = (try? container.decode(Int64.self, forKey: .userId)) ?? 0
            self = .user(id)
        case "messageSenderChat":
            let id = (try? container.decode(Int64.self, forKey: .chatId)) ?? 0
            self = .chat(id)
        default:
            self = .unknown
        }
    }
}

public enum MessageContent: Decodable, Equatable {
    case text(String)
    case photo(String)
    case unsupported
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case text
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "messageText":
            if let nestedContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .text),
               let textValue = try? nestedContainer.decode(String.self, forKey: .text) {
                self = .text(textValue)
            } else {
                self = .text("Text Message")
            }
        case "messagePhoto":
            self = .photo("Photo Message")
        default:
            self = .unsupported
        }
    }
}

public struct MessagesResponse: Decodable {
    public let totalCount: Int
    public let messages: [Message]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case messages
    }
}
