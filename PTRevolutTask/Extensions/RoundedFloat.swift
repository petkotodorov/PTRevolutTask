//
//  RoundedFloat.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/6/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import Foundation

extension Float {
    
    //rounded Float to the second decimal
    var roundedToHundreds: Float {
        return roundf(self * 100) / 100
    }
    
    //rounded Float to the forth decimal
    var roundedToTenThousands: Float {
        return roundf(self * 10000) / 10000
    }
}
