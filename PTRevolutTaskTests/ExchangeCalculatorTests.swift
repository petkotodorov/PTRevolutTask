//
//  ExchangeCalculatorTests.swift
//  PTRevolutTaskTests
//
//  Created by Petko Todorov on 10/4/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import XCTest
@testable import PTRevolutTask

class ExchangeCalculatorTests: XCTestCase {
    
    let euro = CurrencyElement(type: .eur, rate: 1)
    let pound = CurrencyElement(type: .gbp, rate: 0.88793)
    let dollar = CurrencyElement(type: .usd, rate: 1.1753)
    
    var euroRate: Float {
        return euro.rate.roundedToTenThousands
    }
    var poundRate: Float {
        return pound.rate.roundedToTenThousands
    }
    var dollarRate: Float {
        return dollar.rate.roundedToTenThousands
    }
    
    var calculator = ExchangeCalculator()
    
    override func setUp() {
        super.setUp()
        calculator.rates = [euro, pound, dollar]
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEurToEur() {
        let amount: Float = 100
        let result = calculator.exchange(amount, fromCurrency: .eur, toCurrency: .eur)
        XCTAssert(result == amount)
    }
    
    func testEurToUsd() {
        let amount: Float = 100
        let result = calculator.exchange(amount, fromCurrency: .eur, toCurrency: .usd)
        let candidateRate = dollar.rate.roundedToTenThousands
        let candidate = amount * candidateRate
        XCTAssert(result == candidate)
    }
    
    func testEurToGbp() {
        let amount: Float = 100
        let result = calculator.exchange(amount, fromCurrency: .eur, toCurrency: .gbp)
        let candidate = amount * poundRate
        XCTAssert(result == candidate)
    }
    
    func testGbpToUsd() {
        let amount: Float = 100
        let result = calculator.exchange(amount, fromCurrency: .gbp, toCurrency: .usd)
        let candidateRate = (dollarRate/poundRate).roundedToTenThousands
        let candidate = candidateRate * amount
        XCTAssert(result == candidate)
    }
    
    func testGbpToEur() {
        let amount: Float = 100
        let result = calculator.exchange(amount, fromCurrency: .gbp, toCurrency: .eur)
        let candidateRate = (euroRate/poundRate).roundedToTenThousands
        let candidate = candidateRate * amount
        XCTAssert(result == candidate)
    }
    
    func testAmountZero() {
        let amount: Float = 0
        let result = calculator.exchange(amount, fromCurrency: .gbp, toCurrency: .eur)
        XCTAssert(result == 0)
    }
    
    func testNegativeAmount() {
        let amount: Float = -1
        let result = calculator.exchange(amount, fromCurrency: .gbp, toCurrency: .eur)
        XCTAssert(result == 0)
    }
    
    func testExchangeRateText_01() {
        let result = calculator.activeExchangeRate(fromCurrency: .eur, toCurrency: .gbp)
        XCTAssert(result == "1 € = 0.8879 £")
    }
    
    func testExchangeRateText_02() {
        let result = calculator.activeExchangeRate(fromCurrency: .gbp, toCurrency: .eur)
        let candidateRate = (euroRate / poundRate)
        let candidate = candidateRate.roundedToTenThousands
        XCTAssert(result == "1 £ = \(candidate) €")
    }
    
}
