//
//  Currencies.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/4/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import Foundation

enum Currency: String {
    case eur = "EUR"
    case gbp = "GBP"
    case usd = "USD"
}

extension Currency {
    
    var fullName: String {
        switch self {
        case .eur:
            return "Euro"
        case.gbp:
            return "British Pound"
        case.usd:
            return "American Dollar"
        }
    }
    
    var symbol: String {
        switch self {
        case .eur:
            return "€"
        case.gbp:
            return "£"
        case.usd:
            return "$"
        }
    }
    
}
