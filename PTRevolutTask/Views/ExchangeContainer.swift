//
//  ExchangeContainer.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/5/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import UIKit

protocol ExchangeDelegate: class {
    func didReturnActiveRate(_ activeRate: String)
    func didExchange(_ amount: Float, ofCurrency: Currency, andReceived: Float, ofOtherCurrency: Currency)
}

class ExchangeContainer: UIView {
    
    fileprivate var baseCurrencyView: ExchangeScrollView!
    fileprivate var exchangedCurrencyView: ExchangeScrollView!
    
    fileprivate var calculator = ExchangeCalculator()
    var rates = [CurrencyElement]() {
        didSet {
            calculator.rates = rates
            updateScrolls()
            updateActiveRate()
        }
    }
    var accounts = [Account]() {
        didSet {
            initViews()
        }
    }
    
    override func needsUpdateConstraints() -> Bool {
        return true
    }
    
    weak var delegate: ExchangeDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        guard accounts.count > 0 else { return }
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        guard accounts.count > 0 else { return }
        initViews()
    }
    
    fileprivate func initViews() {
        let width = UIScreen.main.bounds.width
        baseCurrencyView = ExchangeScrollView(frame: CGRect(x: 0, y: 0, width: width, height: bounds.height/2))
        baseCurrencyView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(baseCurrencyView)
        NSLayoutConstraint.activate([
            baseCurrencyView.leadingAnchor.constraint(equalTo: leadingAnchor),
            baseCurrencyView.trailingAnchor.constraint(equalTo: trailingAnchor),
            baseCurrencyView.topAnchor.constraint(equalTo: topAnchor),
            baseCurrencyView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5)
        ])
        baseCurrencyView.dataSource = self
        baseCurrencyView.delegate = self
        
        exchangedCurrencyView = ExchangeScrollView(frame: CGRect(x: 0, y: 0, width: width, height: bounds.height/2))
        exchangedCurrencyView.translatesAutoresizingMaskIntoConstraints = false
        exchangedCurrencyView.backgroundColor = .green
        addSubview(exchangedCurrencyView)
        NSLayoutConstraint.activate([
            exchangedCurrencyView.leadingAnchor.constraint(equalTo: leadingAnchor),
            exchangedCurrencyView.trailingAnchor.constraint(equalTo: trailingAnchor),
            exchangedCurrencyView.topAnchor.constraint(equalTo: baseCurrencyView.bottomAnchor),
            exchangedCurrencyView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5)
        ])
        exchangedCurrencyView.dataSource = self
        exchangedCurrencyView.delegate = self
    }
    
    func exchange() throws -> Bool {
        guard let basePage = baseCurrencyView.activePage,
            let baseAccount = basePage.account,
            let exchangedPage = exchangedCurrencyView.activePage,
            let exchangedAccount = exchangedPage.account else { throw ExchangeError.generalError }
        guard baseAccount.currency != exchangedAccount.currency else { throw ExchangeError.sameCurrencies }
        guard basePage.getValue() != 0 else { throw ExchangeError.emptyField }
        guard baseAccount.amount - basePage.getValue() >= 0 else { throw ExchangeError.insufficienFunds }
        
        delegate?.didExchange(basePage.getValue(), ofCurrency: baseAccount.currency, andReceived: exchangedPage.getValue(), ofOtherCurrency: exchangedAccount.currency)
        
        return true
    }
    
    fileprivate func updateScrolls() {
        guard let baseCurrencyField = baseCurrencyView.activePage?.txtFieldAmount,
            let baseAccount = baseCurrencyView.activePage?.account,
            let exchangeCurrencyField = exchangedCurrencyView.activePage?.txtFieldAmount,
            let exchangeAccount = exchangedCurrencyView.activePage?.account else { return }
        
        //check if either ofthe text fields is firstResponder and not empty, and change the value of the other one
        if baseCurrencyField.isFirstResponder {
            guard let currentValue = baseCurrencyField.text,
                let floatValue = Float(currentValue) else { return }
            let newValue = calculator.exchange(floatValue, fromCurrency: baseAccount.currency, toCurrency: exchangeAccount.currency).roundedToHundreds
            baseCurrencyView.activePage?.setTextValue(String(newValue))
        } else if exchangeCurrencyField.isFirstResponder {
            guard let currentValue = exchangeCurrencyField.text,
                let floatValue = Float(currentValue) else { return }
            let newValue = calculator.exchange(floatValue, fromCurrency: exchangeAccount.currency, toCurrency: baseAccount.currency).roundedToHundreds
            exchangedCurrencyView.activePage?.setTextValue(String(newValue))
        }
    }
    
    fileprivate func updateActiveRate() {
        guard let baseCurrency = baseCurrencyView.activePage?.account?.currency,
            let exchangeCurrency = exchangedCurrencyView.activePage?.account?.currency else { return }
        let activeRate = calculator.activeExchangeRate(fromCurrency: baseCurrency, toCurrency: exchangeCurrency)
        delegate?.didReturnActiveRate(activeRate)
    }
    
}

extension ExchangeContainer: ExchangeScrollViewDelegate {
    
    func scrollView(_ scrollView: ExchangeScrollView, returnedValue: Float, forAccount: Account) {
        if scrollView == baseCurrencyView {
            guard let otherAccount = exchangedCurrencyView.activePage?.account else { return }
            let newValue = calculator.exchange(returnedValue, fromCurrency: forAccount.currency, toCurrency: otherAccount.currency).roundedToHundreds
            exchangedCurrencyView.activePage?.setTextValue(String(newValue))
        } else {
            guard let baseAccount = baseCurrencyView.activePage?.account else { return }
            let newValue = calculator.exchange(returnedValue, fromCurrency: forAccount.currency, toCurrency: baseAccount.currency).roundedToHundreds
            baseCurrencyView.activePage?.setTextValue(String(newValue))
        }
    }
    
    
    func scrollView(_ scrollView: ExchangeScrollView, scrolledToAccount account: Account) {
        var activeRate: String!
        
        if scrollView == baseCurrencyView {
            guard let otherAccount = exchangedCurrencyView.activePage?.account else { return }
            //calculate active rate from base currency to exchnaged one
            activeRate = calculator.activeExchangeRate(fromCurrency: account.currency, toCurrency: otherAccount.currency)
            //if there is amount value in the section, which is not scrolled, update the value in the new section
            if let otherValue = exchangedCurrencyView.activePage?.txtFieldAmount.text,
                let floatValue = Float(otherValue) {
                let newValue = calculator.exchange(floatValue, fromCurrency: otherAccount.currency, toCurrency: account.currency).roundedToHundreds
                scrollView.activePage?.setTextValue(String(newValue))
                //reset value in the section, which is not scrolled
            } else {
                exchangedCurrencyView.activePage?.setTextValue("")
            }
        } else {
            guard let otherAccount = baseCurrencyView.activePage?.account else { return }
            //calculate active rate from base currency to exchnaged one
            activeRate = calculator.activeExchangeRate(fromCurrency: otherAccount.currency, toCurrency: account.currency)
            //if there is amount value in the section, which is not scrolled, update the value in the new section
            if let otherValue = baseCurrencyView.activePage?.txtFieldAmount.text,
                let floatValue = Float(otherValue) {
                let newValue = calculator.exchange(floatValue, fromCurrency: otherAccount.currency, toCurrency: account.currency).roundedToHundreds
                scrollView.activePage?.setTextValue(String(newValue))
                //reset value in the section, which is not scrolled
            } else {
                baseCurrencyView.activePage?.setTextValue("")
            }
        }
        delegate?.didReturnActiveRate(activeRate)
    }
    
}

extension ExchangeContainer: ExchangeScrollViewDataSource {
    
    func accountsForItems(inScrollView scrollView: ExchangeScrollView) -> [Account] {
        return accounts
    }
    
    func numberOfItems(inScrollView scrollView: ExchangeScrollView) -> Int {
        return accounts.count
    }

}
