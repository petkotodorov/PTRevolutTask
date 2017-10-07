//
//  NumberFormatting.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/7/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import Foundation

extension String {
    var floatValue: Float {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        if let result = formatter.number(from: self) {
            return result.floatValue
        } else {
            formatter.decimalSeparator = ","
            if let result = formatter.number(from: self) {
                return result.floatValue
            }
        }
        return 0
    }
}

extension Float {
    private static var numberFormatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        formatter.maximumFractionDigits = 2
        formatter.allowsFloats = true
        return formatter
    }()
    
    var stringValue: String {
        if let result = Float.numberFormatter.string(from: NSNumber(value: self)) {
            return result
        }
        return ""
    }
}

