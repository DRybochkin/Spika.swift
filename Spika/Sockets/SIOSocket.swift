//
//  SIOSocket.swift
//  Spika
//
//  Created by Dmitry Rybochkin on 26.01.17.
//  Copyright © 2017 Clover Studio. All rights reserved.
//
import Foundation
import SocketRocket

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

class SIOSocket: NSObject, SRWebSocketDelegate {
    var socket: SRWebSocket!
    var timer: Timer!
    var tryingReConnect: Bool = false
    var reconnectAutomatically: Bool = false
    var host: String!
    var attemptLimit: Int = 0
    var reconnectionDelay: TimeInterval!
    var maximumDelay: TimeInterval!
    var timeout: TimeInterval!
    var attemptDelay: Int = 0
    var handlers: [SocketEventHandler]!
    var queue: [String]!

    var onConnect: onConnectCallback?
    var onDisconnect: onDisconnectCallback?
    var onError: onErrorCallback?
    var onReconnect: onReconnectCallback?
    var onReconnectionAttempt: onReconnectionAttemptCallback?
    var onReconnectionError: onReconnectionErrorCallback?

    // Generators
    class func createSocket (host: String!, reconnectAutomatically: Bool, attemptLimit: Int, reconnectionDelay: TimeInterval!, maximumDelay: TimeInterval!, timeout: TimeInterval!, nsp: String!, response: socketCallback!) {
        let socket = SIOSocket(host: host, reconnectAutomatically: reconnectAutomatically, attemptLimit: attemptLimit, reconnectionDelay: reconnectionDelay, maximumDelay: maximumDelay, timeout: timeout, nsp: nsp, response: response)
        if (response != nil) {
            response(socket)
        }
        socket.connect()
    }
    
    class func createSocket(host: String!, response: socketCallback!) {
        return SIOSocket.createSocket(host: host, reconnectAutomatically: true, attemptLimit: -1, reconnectionDelay: 1, maximumDelay: 5, timeout: 20, nsp: "/spika", response: response)
    }
    
    //initialization
    init(host: String!, reconnectAutomatically: Bool, attemptLimit: Int, reconnectionDelay: TimeInterval!, maximumDelay: TimeInterval!, timeout: TimeInterval!, nsp: String!, response: socketCallback!) {
        super.init()
        
        self.tryingReConnect = false
        self.reconnectAutomatically = reconnectAutomatically
        self.host = host
        self.attemptLimit = attemptLimit
        self.reconnectionDelay = reconnectionDelay
        self.maximumDelay = maximumDelay
        self.timeout = timeout
        self.attemptDelay = 0
        self.handlers = []
        self.queue = []
    }

    func initSocket() {
        if (socket != nil) {
            socket.delegate = nil
            socket.close()
            socket = nil
        }
        let url: URL! = URL(string: host)
        let request: URLRequest! = URLRequest(url: url)
        socket = SRWebSocket(urlRequest: request)
    
        socket.delegate = self
    }
    
    func close() {
        socket.close()
        queue.removeAll()
    }
    
    func connect() {
        tryingReConnect = false
        attemptDelay = 1
        initSocket()
        socket.open()
    }
    
    func reconnect() {
        tryingReConnect = true
        if (timer == nil) {
            timer = Timer(timeInterval: timeout, target: self, selector: #selector(onTimer), userInfo: nil, repeats: reconnectAutomatically)
        }
        if (reconnectAutomatically && attemptDelay < attemptLimit && timer.isValid) {
            timer.fire()
        }
    }
    
    func onTimer() {
        attemptDelay += 1
        if (onReconnectionAttempt != nil) {
            onReconnectionAttempt!(attemptDelay)
        }
        initSocket()
        socket.open()
    }
    
    deinit {
        self.close()
        self.handlers.removeAll()
    }

    // Event responders
    func on(_ event: KAppSocket, callback function: paramsCallback!) {
        //let eventID: String = event.replacingOccurrences(of: " ", with: "_")
        let handler = SocketEventHandler.event(withName: event, andCallback: {(_ items: [Any], _ socket: Any) -> Void in
                print("socket \(event)")
                if (function != nil) {
                    function(items)
                }
            })
        self.handlers.append(handler)
    }
    
    // Emitters
    func emit(_ event: KAppSocket) {
        emit(event, args: nil)
    }

    func emit(_ event: KAppSocket, args: SIOParameterArray!) {
        //пример ["login",{"roomID":"w1","name":"MacBookPro","avatarURL":"","userID":"MacBookPro"}]
        //let eventID: String = event.replacingOccurrences(of: " ", with: "_")
        var arguments: [AnyHashable: Any] = [ "event" : event.rawValue, "data" : "" ]

        for arg: Any in args {
            if (arg is NSNull) {
                arguments["data"] = "null"
            } else if (arg is String) {
                arguments["data"] = String(format: "'%@'", arg as! CVarArg)
            } else if (arg is NSNumber) {
                arguments["data"] = String(format: "'%@'", arg as! CVarArg)
            } else if (arg is Data) {
                let dataString = String(data: arg as! Data, encoding: String.Encoding.utf8)
                arguments["data"] = String(format: "blob('%@')", dataString!)
            } else if (arg is [Any]) || (arg is [AnyHashable: Any]) {
                arguments["data"] = arg
            }
        }
        
        /*TODO проверить формат отправки*/
        /*если сокет не подключен нужно добавить в очередь*/
        let data = try? JSONSerialization.data(withJSONObject: arguments, options: [])
        let str: String! = String(data: data!, encoding: String.Encoding.utf8)
        if (socket != nil && socket.readyState == SRReadyState.OPEN) {
            try? socket.send(string: str)
        }
        else {
            queue.append(str)
        }
    }


    func processEvent(_ event: KAppSocket, data: SIOParameterArray) {
        print("Received \"\(event)\"")
        let events: [SocketEventHandler] = handlers.filter { el in el.isEventEqual(event) }
        for handler: SocketEventHandler in events {
            handler.executeCallback(data, socket: self)
        }
    }
    
    ///--------------------------------------
    // MARK: - SRWebSocketDelegate
    ///--------------------------------------

    func webSocketDidOpen(_ webSocket: SRWebSocket) {
        print("Websocket Connected")
        if (!tryingReConnect && onConnect != nil) {
            onConnect!()
        }
        if (tryingReConnect && onReconnect != nil) {
            onReconnect!(attemptDelay)
        }
        attemptDelay = 0
        if (timer != nil && timer.isValid) {
            timer.invalidate()
        }
        for message: String in queue {
            try? socket.send(string: message)
            queue.remove(at: queue.index(of: message) ?? -1)
        }
    }

    func webSocket(_ webSocket: SRWebSocket, didFailWithError error: Error) {
        print(":( Websocket Failed With Error \(error)")
        if (!tryingReConnect && onError != nil) {
            onError!([NSLocalizedDescriptionKey: error.localizedDescription])
        }
        if (tryingReConnect && onReconnectionError != nil) {
            onReconnectionError!([NSLocalizedDescriptionKey: error.localizedDescription])
        }
        self.socket = nil
        self.reconnect()
    }

    func executeEvent(_ event: String) {
    }

    func webSocket(_ webSocket: SRWebSocket, didReceiveMessageWith string: String) {
        print("Received \"\(string)\"")
        let jsonData: Data = string.data(using: String.Encoding.utf8)!
        var values: [Any]! = try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as! [Any]
        if (values == nil || values.count == 0 || !(values[0] is String)) {
            if (onError != nil) {
                onError!([NSLocalizedDescriptionKey: String(format: "%@ %@", NSLocalizedString("Operation was unsuccessful.", comment: ""), string)])
            }
            return
        }
        let event = KAppSocket(rawValue: (values[0] as! String).replacingOccurrences(of: " ", with: "_"))
        if (event != nil) {
            if (values.count > 1 && (values[1] is [AnyHashable: Any])) {
                processEvent(event!, data: [values[1]])
            }
            else {
                processEvent(event!, data: [])
            }
        }
    }

    func webSocket(_ webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String?, wasClean: Bool) {
        print("WebSocket closed \(Int(code)), \(reason), \(wasClean)")
        if (onDisconnect != nil) {
            onDisconnect!()
        }
        //self.title = @"Connection Closed! (see logs)";
        self.socket = nil
        if (code != 0) {
            self.reconnect()
        }
    }

    func webSocket(_ webSocket: SRWebSocket, didReceivePong pongPayload: Data?) {
        print("WebSocket received pong")
    }
}
