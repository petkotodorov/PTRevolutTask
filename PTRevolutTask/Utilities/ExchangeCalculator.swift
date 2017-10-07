//
//  ExchangeCalculator.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/4/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import Foundation

struct ExchangeCalculator {
    
    var rates = [CurrencyElement]()
    
    //calculates and returns the amount of the currency, being bought
    func exchange(_ amount: Float, fromCurrency: Currency, toCurrency: Currency) -> Float {
        guard amount > 0 else { return 0 }
        guard fromCurrency != toCurrency else { return amount }
        let rate = getRate(fromCurrency: fromCurrency, toCurrency: toCurrency).roundedToTenThousands
        let exchangedAmount = (amount * rate)
        return exchangedAmount
    }
    
    //returns human readable info text about the exchange rate between two currencies, rounded to the forth decimal
    func activeExchangeRate(fromCurrency: Currency, toCurrency: Currency) -> String {
        guard fromCurrency != toCurrency else { return "" }
        let rate = getRate(fromCurrency: fromCurrency, toCurrency: toCurrency).roundedToTenThousands
        return "1 \(fromCurrency.symbol) = \(rate) \(toCurrency.symbol)"
    }
    
    //returns the exchange rate between two currencies, rounded to the forth decimal
    private func getRate(fromCurrency: Currency, toCurrency: Currency) -> Float {
        let fromCurrencyRate = getElement(forCurrency: fromCurrency)
        let toCurrencyRate = getElement(forCurrency: toCurrency)
        guard fromCurrencyRate != nil && toCurrencyRate != nil else { return 0 }
        if fromCurrency == .eur {
            return toCurrencyRate!.rate
        } else {
            return (toCurrencyRate!.rate.roundedToTenThousands / fromCurrencyRate!.rate.roundedToTenThousands)
        }
    }
    
    //gets the coresponding element from the server response
    fileprivate func getElement(forCurrency currency: Currency) -> CurrencyElement? {
        return rates.first { $0.type == currency }
    }
}
