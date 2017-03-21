//
//  CSStickerPageModel.swift
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.

import Foundation

class CSStickerPageModel: CSModel {
    var mainPic: String!
    var list: [CSStickerModel]!

    override class func classForCollectionProperty(propertyName: String!) -> Swift.AnyClass! {
        return CSStickerModel.self
    }
}
