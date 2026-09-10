import Foundation
import Combine

#if canImport(TDLibFramework)
import TDLibFramework
#elseif canImport(TDLib)
import TDLib
#endif

protocol TDLibBridgeProtocol {
    func send<T: Encodable>(request: T)
    var updatesStream: AsyncStream<Data> { get }
    func execute<T: Encodable, R: Decodable>(request: T) -> R?
    func close()
}

final class TDLibBridge: TDLibBridgeProtocol {
    private var client: UnsafeMutableRawPointer?
    private let receiveQueue = DispatchQueue(label: "com.augramx.tdlib.receive", qos: .userInitiated)
    private let sendQueue = DispatchQueue(label: "com.augramx.tdlib.send", qos: .userInitiated)
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private var streamContinuation: AsyncStream<Data>.Continuation?
    private var isRunning = true
    
    lazy var updatesStream: AsyncStream<Data> = {
        AsyncStream { continuation in
            self.streamContinuation = continuation
        }
    }()
    
    init() {
        #if canImport(TDLibFramework) || canImport(TDLib)
        self.client = td_json_client_create()
        startPolling()
        #else
        print("[TDLibBridge] Build Warning: TDLibFramework is not linked in this build configuration.")
        #endif
    }
    
    deinit {
        close()
    }
    
    func close() {
        isRunning = false
        #if canImport(TDLibFramework) || canImport(TDLib)
        if let client = client {
            td_json_client_destroy(client)
            self.client = nil
        }
        #endif
    }
    
    func send<T: Encodable>(request: T) {
        sendQueue.async { [weak self] in
            guard let self = self, let client = self.client else { return }
            guard let data = try? self.encoder.encode(request),
                  let jsonString = String(data: data, encoding: .utf8) else { return }
            
            // SECURITY: Never print sensitive auth requests in logs
            if !(request is SetTdlibParametersRequest || request is CheckAuthenticationPasswordRequest) {
                print("[TDLib Outgoing]: \(jsonString)")
            }
            
            #if canImport(TDLibFramework) || canImport(TDLib)
            td_json_client_send(client, jsonString)
            #endif
        }
    }
    
    func execute<T: Encodable, R: Decodable>(request: T) -> R? {
        guard let data = try? encoder.encode(request),
              let jsonString = String(data: data, encoding: .utf8) else { return nil }
        
        #if canImport(TDLibFramework) || canImport(TDLib)
        if let resultPtr = td_json_client_execute(nil, jsonString) {
            let resultStr = String(cString: resultPtr)
            if let resultData = resultStr.data(using: .utf8) {
                return try? decoder.decode(R.self, from: resultData)
            }
        }
        #endif
        return nil
    }
    
    private func startPolling() {
        receiveQueue.async { [weak self] in
            while let self = self, self.isRunning, let client = self.client {
                #if canImport(TDLibFramework) || canImport(TDLib)
                if let responsePtr = td_json_client_receive(client, 1.0) {
                    let responseStr = String(cString: responsePtr)
                    if let responseData = responseStr.data(using: .utf8) {
                        self.streamContinuation?.yield(responseData)
                    }
                }
                #else
                Thread.sleep(forTimeInterval: 0.1)
                #endif
            }
        }
    }
}
