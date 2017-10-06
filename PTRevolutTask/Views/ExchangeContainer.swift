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
}

class ExchangeContainer: UIView {
    
    fileprivate var baseCurrencyView: ExchangeScrollView!
    fileprivate var exchangedCurrencyView: ExchangeScrollView!
    
    fileprivate var calculator = ExchangeCalculator()
    var rates = [CurrencyElement]() {
        didSet {
            calculator.rates = rates
            updateScrolls()
            //TODO: update the two exchange scrolls
        }
    }
    
    weak var delegate: ExchangeDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    fileprivate func initViews() {
        baseCurrencyView = ExchangeScrollView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height/2))
        baseCurrencyView.dataSource = self
        baseCurrencyView.delegate = self
        addSubview(baseCurrencyView)
        baseCurrencyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            baseCurrencyView.leadingAnchor.constraint(equalTo: leadingAnchor),
            baseCurrencyView.trailingAnchor.constraint(equalTo: trailingAnchor),
            baseCurrencyView.topAnchor.constraint(equalTo: topAnchor),
            baseCurrencyView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5)
        ])
        
        exchangedCurrencyView = ExchangeScrollView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height/2))
        exchangedCurrencyView.backgroundColor = .green
        exchangedCurrencyView.dataSource = self
        exchangedCurrencyView.delegate = self
        addSubview(exchangedCurrencyView)
        exchangedCurrencyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            exchangedCurrencyView.leadingAnchor.constraint(equalTo: leadingAnchor),
            exchangedCurrencyView.trailingAnchor.constraint(equalTo: trailingAnchor),
            exchangedCurrencyView.topAnchor.constraint(equalTo: baseCurrencyView.bottomAnchor),
            exchangedCurrencyView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5)
        ])
    }
    
    func exchange() throws -> Bool {
        guard let baseAccount = baseCurrencyView.activePage?.account,
            let exchangedAccount = exchangedCurrencyView.activePage?.account else {
        throw ExchangeError.generalError
        }
        guard baseAccount.currency != exchangedAccount.currency else { throw ExchangeError.sameCurrencies }
        return true
    }
    
    fileprivate func updateScrolls() {
        
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
//        var baseAccount: Account
//        var otherAccount: Account
        
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
        return User().availableCurrencies
    }
    
    func numberOfItems(inScrollView scrollView: ExchangeScrollView) -> Int {
        return User().availableCurrencies.count
    }

}
