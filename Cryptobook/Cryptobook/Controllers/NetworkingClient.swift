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
    
    func getGlobalData(label1: UILabel, label2: UILabel) -> Void {
        
        Alamofire.request(urlForGlobalData).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let json = JSON(responseData.result.value!)
                
                if let resultData = json.dictionaryObject {
                    self.globalDataResultsDict = resultData as! [String: [String:Any]]
                }
                if let data = self.globalDataResultsDict["data"] {
                    if let _ = data["total_market_cap"] {
                        let marketCapData = data["total_market_cap"] as! [String:Double]
                        var shrunkMarketCap: Double = marketCapData["usd"]!
                        shrunkMarketCap = shrunkMarketCap/1000000000
                        let formattedMarketCap = String(format: "%.2f",shrunkMarketCap)
                        label1.text = "$\(formattedMarketCap) Bn"
                    }
                    if let _ = data["market_cap_percentage"] {
                        let marketCapPercentageData = data["market_cap_percentage"] as! [String:Double]
                        label2.text = String(format: "%.3f",marketCapPercentageData["btc"]!) + "%"
                    }
                }
            }
        }
    }
    
}
