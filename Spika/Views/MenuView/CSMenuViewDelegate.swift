//
//  MenuViewDelegate.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit

protocol CSMenuViewDelegate: NSObjectProtocol {
    func onCamera()
    func onGallery()
    func onLocation()
    func onFile()
    func onVideo()
    func onContact()
    func onAudio()
}
