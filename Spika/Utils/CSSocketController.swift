//
//  SocketController.h
//  SpikaV2
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright © 2015 Clover Studio. All rights reserved.
//
import Foundation

typealias RegisterBlock = (() -> Void)

protocol CSChatSocketControllerDelegate: NSObjectProtocol {
    func socketDidReceiveNewMessage(_ message: CSMessageModel)
    func socketDidReceiveTyping(_ typing: CSTypingModel)
    func socketDidReceiveUserLeft(_ userLeft: CSUserModel)
    func socketDidReceiveMessageUpdated(_ updatedMessages: [CSMessageModel])
    func socketDidReceiveError(_ errorCode: NSNumber)
}

class CSSocketController: NSObject {
    var socket: SIOSocket!
    var queue: [RegisterBlock]!
    var isConnected: Bool = false
    var isConnecting: Bool = false

    static let shared: CSSocketController = {
        let instance = CSSocketController()
        if (!instance.isConnected && !instance.isConnecting) {
            instance.connect()
        }
        return instance
    }()
    
    override init() {
        super.init()
        
        // init code
        isConnected = false
        isConnecting = false
        queue = []
        
    }

    func register(parametersLogin: [AnyHashable: Any]!, delegate: CSChatSocketControllerDelegate!) {
        let block: RegisterBlock = {
            print("registerForChat block execute after connection")
            let array: [Any] = [parametersLogin]
            self.socket.emit(KAppSocket.Login, args: array)
            self.socket.on(KAppSocket.NewMessage, callback: { (_ args: SIOParameterArray?) -> Void in
                let response: [AnyHashable: Any]! = args?.first as! [AnyHashable : Any]!
                var message: CSMessageModel!
                message = try? CSMessageModel(dictionary: response)
                if (delegate != nil) {
                    delegate.socketDidReceiveNewMessage(message)
                }
            })
            self.socket.on(KAppSocket.SendTyping, callback: { (_ args: SIOParameterArray?) -> Void in
                let response: [AnyHashable: Any]! = args?.first as! [AnyHashable : Any]
                var typing: CSTypingModel!
                typing = try? CSTypingModel(dictionary: response)
                if (delegate != nil) {
                    delegate.socketDidReceiveTyping(typing)
                }
            })
            self.socket.on(KAppSocket.UserLeft, callback: { (_ args: SIOParameterArray?) -> Void in
                let response: [AnyHashable: Any]! = args?.first as! [AnyHashable : Any]
                var userLeft: CSUserModel!
                userLeft = try? CSUserModel(dictionary: response)
                if (delegate != nil) {
                    delegate.socketDidReceiveUserLeft(userLeft)
                }
            })
            self.socket.on(KAppSocket.MessageUpdated, callback: { (_ args: SIOParameterArray?) -> Void in
                let response: [AnyHashable: Any]! = args?.first as! [AnyHashable : Any]
                let arrayResponses: [Any]! = Array(response.values)
                var updatedMessages: [CSMessageModel]! = []
                for dict in arrayResponses {
                    let message: CSMessageModel! = try? CSMessageModel(dictionary: dict as! [AnyHashable: Any])
                    updatedMessages.append(message)
                }
                if (delegate != nil) {
                    delegate.socketDidReceiveMessageUpdated(updatedMessages)
                }
            })
            self.socket.on(KAppSocket.Error, callback: { (_ args: SIOParameterArray?) -> Void in
                var response: [AnyHashable: Any]? = args?.first as? [AnyHashable : Any]
                if (delegate != nil) {
                    if (delegate != nil) {
                        delegate.socketDidReceiveError(response?["code"] as! NSNumber)
                    }
                }
            })
        }
        if (!isConnected) {
            queue.append(block)
        } else {
            block()
        }
    }

    func emit(_ event: KAppSocket) {
        socket.emit(event)
    }

    func emit(_ event: KAppSocket, args: SIOParameterArray) {
        socket.emit(event, args: args)
    }

    func close() {
        print("close socket")
        isConnected = false
        socket.close()
    }

   func connect() {
        isConnecting = true
        SIOSocket.createSocket(host: CSCustomConfig.sharedInstance.socket_url, response: { (_ socket: SIOSocket?) -> Void in
            socket?.onConnect = {
                self.isConnected = true
                self.isConnecting = false
                print("connect socket")
                for block in self.queue {
                    block()
                }
                self.queue.removeAll()
            }
            socket?.onError = { (_ errorInfo: [AnyHashable: Any]?) -> Void in
                print("Error socket \(errorInfo)")
            }
            socket?.onDisconnect = {
                self.isConnected = false
                print("disconnect socket")
            }
            socket?.onReconnect = {(_ number: Int) -> Void in
                print("reconnect socket: \(Int(number))")
            }
            socket?.onReconnectionAttempt = {(_ number: Int) -> Void in
                print("reconnect attempt socket: \(Int(number))")
            }
            socket?.onReconnectionError = {(_ errorInfo: [AnyHashable: Any]?) -> Void in
                print("Error socket \(errorInfo)")
            }
            self.socket = socket
        })
    }

    deinit {
        // Should never be called, but just here for clarity really.
    }
}
