//
//  RearrangingArray.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/6/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import Foundation

extension Array {
    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
}
