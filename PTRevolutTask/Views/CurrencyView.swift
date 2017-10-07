//
//  CurrencyView.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/5/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import UIKit

protocol CurrencyViewDelegate: class {
    func didReturnAmount(_ amount: Float, fromSlide slide: CurrencyView)
}

class CurrencyView: UIView {
    
    weak var delegate: CurrencyViewDelegate?

    @IBOutlet weak var lblCurrencyCode: UILabel!
    @IBOutlet weak var lblAvailableAmount: UILabel!
    @IBOutlet weak var txtFieldAmount: UITextField!
    
    //Updates currency type and availability after the property is set
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
    
    //Sets the new text in the textField in the proper format
    func setTextValue(_ value: Float) {
        txtFieldAmount.text = value == 0 ? "" : value.stringValue
    }
    
    //Returns the value of the textField in the proper format
    func getValue() -> Float {
        guard let text = txtFieldAmount.text else { return 0 }
        return text.floatValue
    }
  
}

extension CurrencyView: UITextFieldDelegate {
    
    /**
     Checks:
     -if the decimal separator is only one
     -if the decimal separatot is "," or "."
     -if the number of digits after the separator are max 2
     -if the number of all symbols is max 8
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }
        
        let newText = oldText.replacingCharacters(in: r, with: string)
        let numberOfDots = newText.components(separatedBy: ".").count - 1
        let numberOfComas = newText.components(separatedBy: ",").count - 1

        let numberOfDecimalDigits: Int
        if let dotIndex = newText.index(of: ".") {
            numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
        } else if let comaIndex = newText.index(of: ",") {
            numberOfDecimalDigits = newText.distance(from: comaIndex, to: newText.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }
        if numberOfDots <= 1 && numberOfComas <= 1 && numberOfDecimalDigits <= 2 && newText.count <= 8 {
            let value = newText.count == 0 ? 0 : newText.floatValue
            delegate?.didReturnAmount(value, fromSlide: self)
            return true
        }
        return false
    }
        
}


