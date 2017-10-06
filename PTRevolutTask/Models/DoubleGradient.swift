//
//  DoubleGradient.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/6/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import UIKit

class DoubleGradient : CAGradientLayer {
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        colors = [UIColor.customBlue.cgColor, UIColor.customGreen.cgColor]
        locations = [0.0, 0.7]
    }
    
}
