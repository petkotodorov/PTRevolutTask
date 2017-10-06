//
//  UserData.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/6/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import Foundation

class UserData {
    
    private var user = User()
    
    var userAccounts: [Account] {
        return user.availableCurrencies
    }
    
    func updateAccount(_ account: Currency, withAmount: Float) {
        user.updateAccount(account, withAmount: withAmount)
    }
    
}
