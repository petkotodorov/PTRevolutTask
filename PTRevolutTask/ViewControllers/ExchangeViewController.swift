//
//  ViewController.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/3/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import UIKit

class ExchangeViewController: UIViewController {
    
    @IBOutlet weak var lblActiveRate: ActiveRateLabel!
    @IBOutlet weak var btnExchange: UIButton!
    @IBOutlet weak var currencyContainer: ExchangeContainer!
    
    var userState: UserData!
    var timer: Timer?
    
    fileprivate let repeatInterval: TimeInterval = 30

    override func viewDidLoad() {
        super.viewDidLoad()
        currencyContainer.accounts = userState.userAccounts
        currencyContainer.delegate = self
        
        setTimer()
        
        let gradientLayer = DoubleGradient()
        gradientLayer.frame = view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    @IBAction func onDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onExchange(_ sender: UIButton) {
        var successfulExchange: Bool?
        do {
            try successfulExchange = currencyContainer.exchangeCurrencies()
        } catch ExchangeError.generalError {
            showAlert(withMessage: "The exchange cannot be completed")
        } catch ExchangeError.insufficienFunds {
            showAlert(withMessage: "You have insufficient funds")
        } catch ExchangeError.sameCurrencies {
            showAlert(withMessage: "You cannot exchange the same currency")
        } catch ExchangeError.emptyField {
            showAlert(withMessage: "Please, input amount")
        } catch{
        }
        guard successfulExchange != nil else { return }
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func showLoading(_ flag: Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = flag
        }
    }
    
    fileprivate func setTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: repeatInterval, repeats: true) { [weak self] (_) in
            self?.fetchRates()
        }
        timer?.fire()
    }
    
    fileprivate func fetchRates() {
        self.showLoading(true)
        ApiClient.shared.fetchRates(completionHandler: { (result) -> (Void) in
            self.showLoading(false)
            switch result {
            case .success(let data):
                self.currencyContainer.rates = Parser.parseXml(data)
            case .failure(let errorMessage):
                self.showAlert(withMessage: errorMessage)
            }
        })
    }

}

extension ExchangeViewController: ExchangeDelegate {
    
    func didExchange(_ amount: Float, ofCurrency: Currency, andReceived: Float, ofOtherCurrency: Currency) {
        userState.updateAccount(ofCurrency, withAmount: -amount)
        userState.updateAccount(ofOtherCurrency, withAmount: andReceived)
    }
    
    func didReturnActiveRate(_ activeRate: String) {
        DispatchQueue.main.async {
            self.lblActiveRate.isHidden = activeRate.isEmpty
            self.lblActiveRate.text = activeRate
        }
    }
    
}
