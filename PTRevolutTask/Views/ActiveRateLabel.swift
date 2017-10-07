//
//  ActiveRateView.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/7/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import UIKit

class ActiveRateLabel: UILabel {
    
    private let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.white.cgColor
        layer.masksToBounds = true
        layer.cornerRadius = 10.0
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, padding))
    }
    
    override var intrinsicContentSize : CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height
        return CGSize(width: width, height: heigth)
    }
    
    
    
    

}
