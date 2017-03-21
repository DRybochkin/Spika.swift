//
//  Date+Formatter.swift
//  Spika
//
//  Created by Dmitry Rybochkin on 16.03.17.
//  Copyright © 2017 Clover Studio. All rights reserved.
//

import Foundation

extension Date {
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

}
