//
//  FirstViewController.swift
//  Cryptobook
//
//  Created by Santiago  on 5/17/19.
//  Copyright © 2019 Santiago . All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var marketcapLabel: UILabel!
    @IBOutlet weak var btcdLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var resultsArray = [[String:Any]]()
    var numberOfValuesInResult = 0
    let url: String = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&sparkline=false&price_change_percentage=24h"
    let formatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCryptocurrencies()
        
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(resultsArray.count)
        return resultsArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableCell", for: indexPath) as! HomeTableViewCell
        
        let changePercentage = resultsArray[indexPath.row]["price_change_percentage_24h"] as! Double
        let currentPrice = resultsArray[indexPath.row]["current_price"] as! Double
        let formattedPrice = formatter.string(from: currentPrice as NSNumber)!
        cell.nameLabel.text = (resultsArray[indexPath.row]["name"] as! String)
        cell.symbolLabel.text = (resultsArray[indexPath.row]["symbol"] as! String).capitalized
        cell.dayChangeLabel.text = String(format: "%.2f",changePercentage) + "%"
        cell.priceLabel.text = "$" + formattedPrice
        
        return cell
    }
    
    func getCryptocurrencies() -> Void {
        Alamofire.request(url).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let json = JSON(responseData.result.value!)
                
                if let resultData = json.arrayObject {
                    self.resultsArray = resultData as! [[String:AnyObject]]
                }
                if self.resultsArray.count > 0 {
                    self.numberOfValuesInResult = self.resultsArray.count
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

