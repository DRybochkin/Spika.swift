//
//  CSChatErrorCodes.swift
//  Spika
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright © 2016 Clover Studio. All rights reserved.
//

import Foundation
class CSChatErrorCodes: NSObject {
    private static var codesDictionary: [NSNumber: String] = [1000001: NSLocalizedString("Login No Name", tableName: "CSChatErrorCodes", comment: ""), 1000002: NSLocalizedString("Login No Room ID", tableName: "CSChatErrorCodes", comment: ""), 1000003: NSLocalizedString("Login No User ID", tableName: "CSChatErrorCodes", comment: ""), 1000004: NSLocalizedString("User List No Room ID", tableName: "CSChatErrorCodes", comment: ""), 1000005: NSLocalizedString("Message List No Room ID", tableName: "CSChatErrorCodes", comment: ""), 1000006: NSLocalizedString("Message List No Last Message ID", tableName: "CSChatErrorCodes", comment: ""), 1000007: NSLocalizedString("Send Message No File", tableName: "CSChatErrorCodes", comment: ""), 1000008: NSLocalizedString("Send Message No Room ID", tableName: "CSChatErrorCodes", comment: ""), 1000009: NSLocalizedString("Send Message No User ID", tableName: "CSChatErrorCodes", comment: ""), 1000010: NSLocalizedString("Send Message No Type", tableName: "CSChatErrorCodes", comment: ""), 1000011: NSLocalizedString("File Upload No File", tableName: "CSChatErrorCodes", comment: ""), 1000012: NSLocalizedString("Socket Unknown Error", tableName: "CSChatErrorCodes", comment: ""), 1000013: NSLocalizedString("Socket Delete Message No User ID", tableName: "CSChatErrorCodes", comment: ""), 1000014: NSLocalizedString("Socket Delete Message No Message ID", tableName: "CSChatErrorCodes", comment: ""), 1000015: NSLocalizedString("Socket Send Message No Room ID", tableName: "CSChatErrorCodes", comment: ""), 1000016: NSLocalizedString("Socket Send Message No User Id", tableName: "CSChatErrorCodes", comment: ""), 1000017: NSLocalizedString("Socket Send Message No Type", tableName: "CSChatErrorCodes", comment: ""), 1000018: NSLocalizedString("Socket Send Message No Message", tableName: "CSChatErrorCodes", comment: ""), 1000019: NSLocalizedString("Socket Send Message No Location", tableName: "CSChatErrorCodes", comment: ""), 1000020: NSLocalizedString("Socket Send Message Fail", tableName: "CSChatErrorCodes", comment: ""), 1000021: NSLocalizedString("Socket Typing No User ID", tableName: "CSChatErrorCodes", comment: ""), 1000022: NSLocalizedString("Socket Typing No Room ID", tableName: "CSChatErrorCodes", comment: ""), 1000023: NSLocalizedString("Socket Typing No Type", tableName: "CSChatErrorCodes", comment: ""), 1000024: NSLocalizedString("Socket Typing Faild", tableName: "CSChatErrorCodes", comment: ""), 1000025: NSLocalizedString("Socket Login No User ID", tableName: "CSChatErrorCodes", comment: ""), 1000026: NSLocalizedString("Socket Login No Room ID", tableName: "CSChatErrorCodes", comment: "")]

    static func error(forCode code: NSNumber) -> String! {
        return codesDictionary[code]
    }
}
