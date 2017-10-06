//
//  CurrencyInfoTableViewCell.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/4/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import UIKit

class CurrencyInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblCurrency: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblAmount.textColor = .white
        lblCurrency.textColor = .white
    }


}
