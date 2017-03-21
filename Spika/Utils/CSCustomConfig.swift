//
//  CSCustomConfig.swift
//  Spika
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright © 2015 Clover Studio. All rights reserved.
//

import Foundation

class CSCustomConfig: NSObject {
    var server_url: String!
    var socket_url: String!
    
    static let sharedInstance: CSCustomConfig = {
        let instance = CSCustomConfig()
        return instance
    }()

    override init() {
        super.init()
        server_url = kAppBaseUrl
        socket_url = kAppSocketURL
    }
}
