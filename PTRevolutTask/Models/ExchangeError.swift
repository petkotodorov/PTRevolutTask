//
//  ExchangeError.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/6/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import Foundation

enum ExchangeError: Error {
    case insufficienFunds
    case sameCurrencies
    case generalError
    case emptyField
}
