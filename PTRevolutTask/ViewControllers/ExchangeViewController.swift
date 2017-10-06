//
//  ViewController.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/3/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import UIKit

class ExchangeViewController: UIViewController {
    
    @IBOutlet weak var lblActiveRate: UILabel!
    @IBOutlet weak var btnExchange: UIButton!
    @IBOutlet weak var currencyContainer: ExchangeContainer!
    
    var userInfo: User!
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        continuousFetching()
        currencyContainer.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    @IBAction func onDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onExchange(_ sender: UIButton) {
        var result: Bool?
        do {
            try result = currencyContainer.exchange()
        } catch ExchangeError.generalError {
            showAlert(withTitle: "Error", withMessage: "The exchange cannot be completed")
        } catch ExchangeError.insufficienFunds {
            showAlert(withTitle: "Error", withMessage: "You have insufficient funds")
        } catch ExchangeError.sameCurrencies {
            showAlert(withTitle: "Error", withMessage: "You cannot exchange the same currency")
        } catch ExchangeError.emptyField {
            showAlert(withTitle: "Error", withMessage: "Please, input amount")
        } catch{
        }
        guard result != nil else { return }
        showAlert(withTitle: "Ok", withMessage: "Success")
    }
    
    fileprivate func showLoading(_ flag: Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = flag
        }
        
    }
    
    fileprivate func continuousFetching() {
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] (_) in
            self?.showLoading(true)
            ApiClient.shared.fetchRates(completionHandler: { (result) -> (Void) in
                self?.showLoading(false)
                switch result {
                case .success(let data):
                    self?.currencyContainer.rates = Parser.parseXml(data)
                case .failure(let errorMessage):
                    self?.showAlert(withTitle: "Error", withMessage: errorMessage)
                }
            })
        }
        timer?.fire()
    }

}

extension ExchangeViewController: ExchangeDelegate {
    func didReturnActiveRate(_ activeRate: String) {
        DispatchQueue.main.async {
            self.lblActiveRate.text = activeRate
        }
    }
    
}
