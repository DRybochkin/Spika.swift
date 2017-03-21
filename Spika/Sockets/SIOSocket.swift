//
//  SIOSocket.swift
//  Spika
//
//  Created by Dmitry Rybochkin on 26.01.17.
//  Copyright © 2017 Clover Studio. All rights reserved.
//
import Foundation
import SocketIO

// NSArray of these JSValue-valid objects:
typealias SIOParameterArray = [Any]
// --------------------
//        NSNull
//       NSString
//       NSNumber
//     NSDictionary
//       NSArray
//        NSData
// --------------------
typealias paramsCallback = (_ args: SIOParameterArray?) -> Void
typealias socketCallback = (_ socket: SIOSocket?) -> Void

typealias onConnectCallback = () -> Void
typealias onDisconnectCallback = () -> Void
typealias onErrorCallback = (_ errorInfo: [AnyHashable: Any]?) -> Void
typealias onReconnectCallback = (_ numberOfAttempts: Int) -> Void
typealias onReconnectionAttemptCallback = (_ numberOfAttempts: Int) -> Void
typealias onReconnectionErrorCallback = (_ errorInfo: [AnyHashable: Any]?) -> Void

class SIOSocket: NSObject {
    var socket: SocketIOClient!

    var onConnect: onConnectCallback?
    var onDisconnect: onDisconnectCallback?
    var onError: onErrorCallback?
    var onReconnect: onReconnectCallback?
    var onReconnectionAttempt: onReconnectionAttemptCallback?
    var onReconnectionError: onReconnectionErrorCallback?

    //initialization
    init(host: String!, reconnectAutomatically: Bool, attemptLimit: Int, reconnectionDelay: TimeInterval!, maximumDelay: TimeInterval!, timeout: TimeInterval!, nsp: String!, response: socketCallback!) {
        super.init()
        
        self.socket = SocketIOClient(socketURL: URL(string: host)!, config: [SocketIOClientOption.log(true), SocketIOClientOption.nsp(nsp), SocketIOClientOption.reconnects(reconnectAutomatically), SocketIOClientOption.reconnectAttempts(attemptLimit), SocketIOClientOption.reconnectWait(Int(timeout))])
    }

    // Generators
    class func socketWithHost(host: String!, response: socketCallback!) {
        return SIOSocket.socketWithHost(host: host, reconnectAutomatically: true, attemptLimit: -1, reconnectionDelay: 1, maximumDelay: 5, timeout: 20, nsp: "/spika", response: response)
    }
    
    class func socketWithHost(host: String!, reconnectAutomatically: Bool, attemptLimit: Int, reconnectionDelay: TimeInterval!, maximumDelay: TimeInterval!, timeout: TimeInterval!, nsp: String!, response: socketCallback!) {
        let socket = SIOSocket(host: host, reconnectAutomatically: reconnectAutomatically, attemptLimit: attemptLimit, reconnectionDelay: reconnectionDelay, maximumDelay: maximumDelay, timeout: timeout, nsp: nsp, response: response)
        if (response != nil) {
            response(socket)
        }
        socket.socket.connect()
        
        socket.socket.on("connect", callback: { (_ data: [Any], _ ask: SocketAckEmitter) -> Void in
            NSLog("socket connected")
            if (socket.onConnect != nil) {
                socket.onConnect!()
            }
        })
        
        socket.socket.on("disconnect", callback: { (_ data: [Any], _ ask: SocketAckEmitter) -> Void in
            NSLog("socket disconnected")
            if (socket.onDisconnect != nil) {
                socket.onDisconnect!()
            }
        })
        
        socket.socket.on("error", callback: { (_ data: [Any], _ ask: SocketAckEmitter) -> Void in
            NSLog("socket error")
            if (socket.onError != nil) {
                socket.onError!(["data": data])
            }
        })
        
        socket.socket.on("reconnect", callback: { (_ data: [Any], _ ask: SocketAckEmitter) -> Void in
            NSLog("socket reconnect")
            if (socket.onReconnect != nil) {
                socket.onReconnect!(data.count)
            }
        })

        socket.socket.on("reconnectAttempt", callback: { (_ data: [Any], _ ask: SocketAckEmitter) -> Void in
            NSLog("socket reconnectAttempt")
            if (socket.onReconnectionAttempt != nil) {
                socket.onReconnectionAttempt!(data.count)
            }
        })

        socket.socket.onAny( { (event: SocketAnyEvent) -> Void in
            NSLog("socket anyevent %@", event)
        })
        
        response(socket);
    }
    
    deinit {
        self.close()
    }
    
    func close() {
        socket.disconnect()
    }
    
    // Event responders
    func on(_ event: String, callback function: @escaping (_ args: SIOParameterArray?) -> Void) {
        let eventID: String = event.replacingOccurrences(of: " ", with: "_")
        self.socket.on(eventID, callback: {(_ data: [Any], _ ack: SocketAckEmitter) -> Void in
            print("socket \(event)")
            function(data)
        })
    }
    // Emitters
    
    func emit(_ event: String) {
        emit(event, args: nil)
    }
    
    func emit(_ event: String, args: SIOParameterArray?) {
        let eventID: String = event.replacingOccurrences(of: " ", with: "_")
        socket.emit(eventID, with: args!)
    }
}
