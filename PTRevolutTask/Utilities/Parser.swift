//
//  Parser.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/3/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import Foundation
import SWXMLHash

struct Parser {
    
    static func parseXml(_ xmlData: Data) -> [CurrencyElement] {
        var elements = [CurrencyElement]()
        let xml = SWXMLHash.parse(xmlData)
        for index in xml["gesmes:Envelope"]["Cube"]["Cube"]["Cube"].all {
            if let element = CurrencyElement.deserialize(index.element) {
                elements.append(element)
            }
        }
        elements.append(CurrencyElement(type: .eur, rate: 1))
        return elements
    }
}
