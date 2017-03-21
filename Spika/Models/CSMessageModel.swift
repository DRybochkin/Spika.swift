//
//  CSMessageModel.swift
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//
import Foundation
import UIKit
import JSONModel

class CSMessageModel: CSModel {
    var id: String!
    var userID: String!
    var roomID: String!
    var user: CSUserModel!
    var messageType: KAppMessageType!
    var type: NSNumber! {
        didSet {
            messageType = KAppMessageType(rawValue: type.intValue)!
        }
    }
    var message: String!
    var created: Date!
    var file: CSFileModel!
    var localID: String!
    var location: CSLocationModel!
    var seenBy: [CSSeenByModel]!
    var deleted: Date!
    var messageStatus: KAppMessageStatus = KAppMessageStatus.Received
    var status: NSNumber! {
        didSet {
            messageStatus = KAppMessageStatus(rawValue: status.intValue)!
        }
    }

    static func createMessage(user: CSUserModel!, message: String!, type: KAppMessageType!, file: CSFileModel!, location: CSLocationModel!) -> CSMessageModel {
        let messageForReturn = CSMessageModel()
        messageForReturn.user = user
        messageForReturn.userID = user.userID
        messageForReturn.roomID = user.roomID
        messageForReturn.type = NSNumber(value: type.rawValue)
        messageForReturn.status = NSNumber(value: KAppMessageStatus.Sent.rawValue)
        messageForReturn.message = message
        messageForReturn.localID = messageForReturn.generateLocalIDwithLength(32)
        messageForReturn.created = Date()
        if (file != nil) {
            messageForReturn.file = file
        }
        if (location != nil) {
            messageForReturn.location = location
        }
        return messageForReturn
    }

    func updateMessage(withData data: CSMessageModel) {
        self.seenBy = data.seenBy
        self.deleted = data.deleted
    }


    func generateLocalIDwithLength(_ length: Int) -> String {
        var AB: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"
        var randomString: String = ""
        for _ in 0..<length {
            let randomIndex = Int(arc4random_uniform(UInt32(AB.characters.count)))
            let char = AB[AB.index(AB.startIndex, offsetBy: randomIndex)]
            randomString.append(char)
        }
        return randomString
    }
    
    override class func keyMapper() -> JSONKeyMapper! {
        return JSONKeyMapper(modelToJSONDictionary: ["id":"_id"])
    }

    override class func classForCollectionProperty(propertyName: String!) -> Swift.AnyClass! {
        return CSSeenByModel.self
    }
}
