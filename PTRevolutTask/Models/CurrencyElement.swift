//
//  CurrencyElement.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/3/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import Foundation
import SWXMLHash

struct CurrencyElement {
    let type: Currency
    let rate: Float
    
    static func deserialize(_ element: XMLElement?) -> CurrencyElement? {
        guard let stringName = element?.attribute(by: "currency")?.text else { return nil }
        guard let stringRate = element?.attribute(by: "rate")?.text else { return nil }
        if stringName != "USD" && stringName != "GBP" { return nil }
        
        guard let name = Currency(rawValue: stringName) else { return nil }
        guard let rate = Float(stringRate) else { return nil }
        return CurrencyElement(type: name, rate: rate.roundedToTenThousands)
    }
}

