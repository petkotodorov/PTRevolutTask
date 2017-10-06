//
//  User.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/4/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import Foundation

struct User {
    var availableCurrencies = [Account(currency: .eur, amount: 100),
                               Account(currency: .gbp, amount: 100),
                               Account(currency: .usd, amount: 100)]
    
    func getAmountInfo(forCurrency currency: Currency) -> String {
        if let account = availableCurrencies.first(where: { $0.currency == currency }) {
            let amount = account.amount.roundedToHundreds
            return "You have \(amount) \(currency.symbol)"
        }
        return ""
    }
    
    mutating func updateAccount(_ account: Currency, withAmount: Float) {
        let index = availableCurrencies.index { (item) -> Bool in
            item.currency == account
        }
        if let index = index {
            availableCurrencies[index].amount = availableCurrencies[index].amount + withAmount
        }
    }
    
}
