//
//  NetworkingClient.swift
//  Cryptobook
//
//  Created by Santiago  on 5/22/19.
//  Copyright © 2019 Santiago . All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkingClient {
    
    var resultsArray = [[String:Any]]()
    var globalDataResultsDict = [String : [String:Any]]()
    var numberOfValuesInResult = 0
    let urlForCryptocurrencies: String = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&sparkline=false&price_change_percentage=24h"
    let urlForGlobalData = "https://api.coingecko.com/api/v3/global"
    
    
    
    func getCryptocurrencies(table: UITableView) -> Void {
        Alamofire.request(urlForCryptocurrencies).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let json = JSON(responseData.result.value!)
                
                if let resultData = json.arrayObject {
                    self.resultsArray = resultData as! [[String:AnyObject]]
                }
                if self.resultsArray.count > 0 {
                    self.numberOfValuesInResult = self.resultsArray.count
                    table.reloadData()
                }
            }
        }
    }
    
    /*func getGlobalData(label1: UILabel, label2: UILabel) -> Void {
        Alamofire.request(urlForGlobalData).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let json = JSON(responseData.result.value!)
                
                if let resultData = json.dictionary {
                    self.globalDataResultsDict = resultData as [String: [String:Any]]
                }
                if let data = self.globalDataResultsDict["data"] {
                    label1.text = String(self.globalDataResultsDict["total_market_cap"]["usd"] as! Double)
                }
            }
        }
    }*/
    
}
