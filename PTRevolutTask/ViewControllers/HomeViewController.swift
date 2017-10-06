//
//  HomeViewController.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/4/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tblAccountInfo: UITableView!
    
    var userInfo = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.tblAccountInfo.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ExchangeViewController {
            vc.userInfo = userInfo
        }
    }

}

extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyInfoTableViewCell", for: indexPath) as? CurrencyInfoTableViewCell {
            let elem = userInfo.availableCurrencies[indexPath.row]
            cell.lblAmount.text = "\(elem.amount) \(elem.currency.symbol)"
            cell.lblCurrency.text = "\(elem.currency.rawValue) - \(elem.currency.fullName)"
            return cell
        }
        return UITableViewCell()
    }
    
    
}
