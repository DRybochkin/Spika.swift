//
//  CSStickerDelegate.swift
//  Spika
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import Foundation

protocol CSStickerDelegate: NSObjectProtocol {
    func onSticker(_ stickerUrl: String)
}
