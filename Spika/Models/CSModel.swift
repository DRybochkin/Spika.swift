//
//  CSModel.swift
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.

import Foundation
import JSONModel

public class CSModel: JSONModel {
    var messageM: String!

    //+(JSONKeyMapper*)keyMapper
    //{
    //    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
    //}

    override public class func propertyIsOptional(_ propertyName: String) -> Bool {
        return true
    }
}
