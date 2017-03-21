//
//  CSFileDetailsModel.swift
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.

class CSFileDetailsModel: CSModel {
    var id: String!
    var name: String!
    var size: String!
    var mimeType: String! {
        didSet {
            fileType = KAppMediaType(rawValue: mimeType)!
        }
    }
    var fileType: KAppMediaType!
}
