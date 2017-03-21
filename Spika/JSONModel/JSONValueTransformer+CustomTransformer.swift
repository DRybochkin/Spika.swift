//
//  JSONValueTransformer+CustomTransformer.swift
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import Foundation
import JSONModel

extension JSONValueTransformer {
    open class func NSDate(byResolvingClusterClasses sourceClass: Swift.AnyClass!) -> Swift.AnyClass! {
        if (sourceClass == NSString.self) {
            return Date.self as! AnyClass
        }
        return sourceClass
    }
    
    func NSDateFromNSString(_ string: String) -> Date! {
        let dateFormatter = DateFormatter()
        //[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"]];
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZZZZZZ"
        return dateFormatter.date(from: string)!
    }
    
    func KAppMessageTypeFromNSNumber(_ number: NSNumber) -> KAppMessageType {
        return KAppMessageType(rawValue: number.intValue)!
    }

    func KAppMessageTypeFromNSInteger(_ integer: NSInteger) -> KAppMessageType {
        return KAppMessageType(rawValue: integer)!
    }

    func NSArrayFromNSString(_ string: String) -> [Any]! {
        return nil
    }

    func NSArrayFromNSNumber(_ number: NSNumber) -> [Any]! {
        return nil
    }
    
    func NSArrayFromNSDictionary(_ dictionary: [AnyHashable: Any]!) -> [Any]! {
        return Array(dictionary.values)
    }

    func NSMutableArrayFromNSNumber(_ number: NSNumber) -> [Any]! {
        return nil
    }

    func NSMutableArrayFromNSString(_ string: String) -> [Any]! {
        return nil
    }
    
    func NSMutableArrayFromNSDictionary(_ dictionary: [AnyHashable: Any]!) -> [Any]! {
        return Array(dictionary.values)
    }

    func NSDictionaryFromNSMutableArray(_ array: [Any]!) -> [AnyHashable: Any]! {
        return ["0": array]
    }

    func NSDictionaryFromNSArray(_ array: [Any]!) -> [AnyHashable: Any]! {
        return ["0": array]
    }

    func NSStringFromNSArray(_ array: [Any]) -> String! {
        return nil
    }
    
    func NSStringFromNSDictionary(_ dictionary: [AnyHashable: Any]) -> String! {
        return nil
    }

    func NSNumberFromNSArray(_ array: [Any]) -> NSNumber! {
        return nil
    }
    func NSNumberFromNSDictionary(_ dictionary: [AnyHashable: Any]) -> NSNumber! {
        return nil
    }

}

