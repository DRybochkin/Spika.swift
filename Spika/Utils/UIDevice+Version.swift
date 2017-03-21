//
//  UIDevice+Version.swift
//  Spika
//
//  Created by Dmitry Rybochkin on 16.03.17.
//  Copyright © 2017 Clover Studio. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    open class func getVersion() -> Double {
        var str: String! = UIDevice.current.systemVersion
        var found = false
        let replaced = String(str.characters.map {
            if ($0 == ".") {
                if (found) {
                    return "0"
                }
                found = true
            }
            return $0
        })
        let res = Double(replaced)
        if (res != nil) {
            return res!
        }
        return Double(0)
    }
}
