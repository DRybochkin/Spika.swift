//
//  CSTypingModel.swift
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.

import Foundation

class CSTypingModel: CSModel {
    var userID: String!
    var typingType: KAppTypingStatus!
    var type: NSNumber! {
        didSet {
            typingType = KAppTypingStatus(rawValue: type.intValue)!
        }
    }
    var roomID: String!
    var user: CSUserModel!
}
