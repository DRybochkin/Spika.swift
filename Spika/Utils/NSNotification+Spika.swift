//
//  NSNotification+Spika.swift
//  Spika
//
//  Created by Dmitry Rybochkin on 16.03.17.
//  Copyright © 2017 Clover Studio. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    public static var SpikaDeleteMessageNotification: NSNotification.Name = NSNotification.Name("SpikaDeleteMessageNotification")
    public static var SpikaFileUploadedNotification: NSNotification.Name = NSNotification.Name("SpikaFileUploadedNotification")
    public static var SpikaLocationSelectedNotification: NSNotification.Name = NSNotification.Name("SpikaLocationSelectedNotification")
}
