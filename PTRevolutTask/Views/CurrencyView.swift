//
//  CurrencyView.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/5/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import UIKit

protocol CurrencyViewDelegate: class {
    func didReturnValue(_ value: Float, fromPage page: CurrencyView)
}

class CurrencyView: UIView {
    
    weak var delegate: CurrencyViewDelegate?

    @IBOutlet weak var lblCurrencyCode: UILabel!
    @IBOutlet weak var lblAvailableAmount: UILabel!
    @IBOutlet weak var txtFieldAmount: UITextField!
    
    var account: Account? {
        didSet {
            if account != nil {
                lblCurrencyCode.text = account!.currency.rawValue
                lblAvailableAmount.text = "You have \(account!.amount.roundedToHundreds) \(account!.currency.symbol)"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        txtFieldAmount.keyboardType = .decimalPad
        txtFieldAmount.borderStyle = .none
        txtFieldAmount.textAlignment = .right
        txtFieldAmount.textColor = .white
        txtFieldAmount.tintColor = .white
        txtFieldAmount.adjustsFontSizeToFitWidth = false
        txtFieldAmount.delegate = self
    }
    
    func setTextValue(_ value: Float) {
        txtFieldAmount.text = value == 0 ? "" : String(value)
    }
    
    func getValue() -> Float {
        guard let text = txtFieldAmount.text,
            let floatValue = Float(text) else { return 0 }
        return floatValue
    }
  
}

extension CurrencyView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }
        
        let newText = oldText.replacingCharacters(in: r, with: string)
        let isNumeric = newText.isEmpty || (Double(newText) != nil)
        let numberOfDots = newText.components(separatedBy: ".").count - 1
        
        let numberOfDecimalDigits: Int
        if let dotIndex = newText.index(of: ".") {
            numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }
        if isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2 && newText.count <= 8 {
            let value = newText.count == 0 ? 0 : Float(newText)
            delegate?.didReturnValue(value!, fromPage: self)
            return true
        }
        return false
    }
        
}


