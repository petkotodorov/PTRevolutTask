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
        baseCurrencyView.backgroundColor = UIColor.customBlue
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
        exchangedCurrencyView.backgroundColor = UIColor.customGreen
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
    
    func exchangeCurrencies() throws -> Bool {
        guard let basePage = baseCurrencyView.activePage,
            let baseAccount = basePage.account,
            let exchangedPage = exchangedCurrencyView.activePage,
            let exchangedAccount = exchangedPage.account else { throw ExchangeError.generalError }
        guard baseAccount.currency != exchangedAccount.currency else { throw ExchangeError.sameCurrencies }
        guard basePage.getValue() != 0 else { throw ExchangeError.emptyField }
        guard baseAccount.amount - basePage.getValue() >= 0 else { throw ExchangeError.insufficienFunds }
        
        delegate?.didExchange(basePage.getValue(),
                              ofCurrency: baseAccount.currency,
                              andReceived: exchangedPage.getValue(),
                              ofOtherCurrency: exchangedAccount.currency)
        
        return true
    }
    
    fileprivate func updateScrolls() {
        guard let baseCurrencyField = baseCurrencyView.activePage?.txtFieldAmount,
            let baseAccount = baseCurrencyView.activePage?.account,
            let exchangeCurrencyField = exchangedCurrencyView.activePage?.txtFieldAmount,
            let exchangeAccount = exchangedCurrencyView.activePage?.account else { return }
        
        //check if either of the text fields is firstResponder and not empty, and change the value of the other one
        if baseCurrencyField.isFirstResponder {
            guard let currentAmount = baseCurrencyView.activePage?.getValue() else { return }
            let newAmount = calculator.exchange(currentAmount, fromCurrency: baseAccount.currency, toCurrency: exchangeAccount.currency).roundedToHundreds
            exchangedCurrencyView.activePage?.setTextValue(newAmount)
        } else if exchangeCurrencyField.isFirstResponder {
            guard let currentAmount = exchangedCurrencyView.activePage?.getValue() else { return }
            let newAmount = calculator.exchange(currentAmount, fromCurrency: exchangeAccount.currency, toCurrency: baseAccount.currency).roundedToHundreds
            baseCurrencyView.activePage?.setTextValue(newAmount)
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
            let newAmount = calculator.exchange(returnedValue, fromCurrency: forAccount.currency, toCurrency: otherAccount.currency).roundedToHundreds
            exchangedCurrencyView.activePage?.setTextValue(newAmount)
            baseCurrencyView.activePage?.lblAvailableAmount.textColor = forAccount.amount - returnedValue < 0 ? .red : .white
        } else {
            guard let baseAccount = baseCurrencyView.activePage?.account else { return }
            let newAmount = calculator.exchange(returnedValue, fromCurrency: forAccount.currency, toCurrency: baseAccount.currency).roundedToHundreds
            baseCurrencyView.activePage?.setTextValue(newAmount)
            baseCurrencyView.activePage?.lblAvailableAmount.textColor = baseAccount.amount - newAmount < 0 ? .red : .white
        }
    }
    
    
    func scrollView(_ scrollView: ExchangeScrollView, scrolledToAccount account: Account) {
        var activeRate: String!
        
        if scrollView == baseCurrencyView {
            guard let otherAccount = exchangedCurrencyView.activePage?.account else { return }
            //calculate active rate from base currency to exchnaged one
            activeRate = calculator.activeExchangeRate(fromCurrency: account.currency, toCurrency: otherAccount.currency)
            //if there is amount value in the section, which is not scrolled, update the value in the new section
            if let amount = exchangedCurrencyView.activePage?.getValue() {
                let newAmount = calculator.exchange(amount, fromCurrency: otherAccount.currency, toCurrency: account.currency).roundedToHundreds
                scrollView.activePage?.setTextValue(newAmount)
                //reset value in the section, which is not scrolled
            } else {
                exchangedCurrencyView.activePage?.setTextValue(0)
            }
        } else {
            guard let otherAccount = baseCurrencyView.activePage?.account else { return }
            //calculate active rate from base currency to exchnaged one
            activeRate = calculator.activeExchangeRate(fromCurrency: otherAccount.currency, toCurrency: account.currency)
            //if there is amount value in the section, which is not scrolled, update the value in the new section
            if let amount = baseCurrencyView.activePage?.getValue() {
                let newAmount = calculator.exchange(amount, fromCurrency: otherAccount.currency, toCurrency: account.currency).roundedToHundreds
                scrollView.activePage?.setTextValue(newAmount)
                //reset value in the section, which is not scrolled
            } else {
                baseCurrencyView.activePage?.setTextValue(0)
            }
        }
        delegate?.didReturnActiveRate(activeRate)
    }
    
}

extension ExchangeContainer: ExchangeScrollViewDataSource {
    
    func accountsForItems(inScrollView scrollView: ExchangeScrollView) -> [Account] {
        //rearrange randomly the array for the second scroll view, in order ho have different currencies visible
        if scrollView == exchangedCurrencyView {
            var tempArray = accounts
            tempArray.rearrange(from: 0, to: accounts.count - 1)
            return tempArray
        }
        return accounts
    }
    
    func numberOfItems(inScrollView scrollView: ExchangeScrollView) -> Int {
        return accounts.count
    }

}
