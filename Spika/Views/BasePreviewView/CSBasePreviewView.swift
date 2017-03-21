//
//  BasePreviewView.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit

typealias dismissPreview = (_: Void) -> Void

class CSBasePreviewView: UIView {
    var dismiss: dismissPreview!
    var message: CSMessageModel!

    func initializeView(message: CSMessageModel!, size: Float, dismiss: dismissPreview!) {
    }
}
