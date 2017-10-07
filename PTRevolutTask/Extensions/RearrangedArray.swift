//
//  RearrangingArray.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/6/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import Foundation

extension Array {
    
    //rearranges an element of array to a new position
    mutating func rearrange(from: Int, to: Int) {
        guard !self.isEmpty,
            from >= 0,
            from < self.count,
            to >= 0,
            to < self.count else { return }
        insert(remove(at: from), at: to)
    }
    
}
