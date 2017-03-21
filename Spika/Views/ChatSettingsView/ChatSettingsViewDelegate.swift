//
//  ChatSettingsViewDelegate.swift
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit

protocol CSChatSettingsViewDelegate: NSObjectProtocol {
    func onSettingsClickedPosition(_ position: Int)
    func onDismissClicked()
}
