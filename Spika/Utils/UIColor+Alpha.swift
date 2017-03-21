//
//  UIColor+Alpha.swift
//  Spika
//
//  Created by Dmitry Rybochkin on 16.03.17.
//  Copyright © 2017 Clover Studio. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    open class func kAppDefaultColor(alpha: CGFloat) -> UIColor {
        return UIColor( red: CGFloat(0 / 255.0), green: CGFloat(158/255.0), blue: CGFloat(159/255.0), alpha: alpha)
    }

    open class func kAppGrayLight(alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(218/255.0), green: CGFloat(218/255.0), blue: CGFloat(218/255.0), alpha:alpha)
    }

    open class func kAppInfoUserMessageColor(alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(102/255.0), green: CGFloat(102/255.0), blue: CGFloat(102/255.0), alpha:alpha)
    }

    open class func kAppBlackColor(alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(0/255.0), green: CGFloat(0/255.0), blue: CGFloat(0/255.0), alpha: alpha)
    }
}
