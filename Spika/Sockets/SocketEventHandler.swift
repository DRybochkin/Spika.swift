//
//  SocketEventHandler.swift
//  Spika
//
//  Created by Dmitry Rybochkin on 31.01.17.
//  Copyright © 2017 Clover Studio. All rights reserved.
//
import Foundation

typealias SocketEventHandlerCallback = ((_ items: [Any], _ socket: Any) -> Void)

class SocketEventHandler: NSObject {
    var event: KAppSocket = KAppSocket.Error
    var callback: SocketEventHandlerCallback! = nil

    class func event(withName event: KAppSocket, andCallback callback: SocketEventHandlerCallback!) -> SocketEventHandler {
        return SocketEventHandler(event, andCallback: callback)
    }

    func executeCallback(_ items: [Any], socket: Any) {
        if (callback != nil) {
            callback(items, socket)
        }
    }

    func isEventEqual(_ eventName: KAppSocket) -> Bool {
        return (event == eventName)
    }


    init(_ eventName: KAppSocket, andCallback callback: SocketEventHandlerCallback!) {
        super.init()
        
        event = eventName
        self.callback = callback
    }
}
