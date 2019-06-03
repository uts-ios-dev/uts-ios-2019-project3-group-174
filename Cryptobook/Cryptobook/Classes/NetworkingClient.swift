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
    var coinPriceResultDict = [String : [String:Double]]()
    var numberOfValuesInResult = 0
    let urlForCryptocurrencies: String = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&sparkline=false&price_change_percentage=24h"
    
    let urlForGlobalData = "https://api.coingecko.com/api/v3/global"
    
    var urlForCoinPrices: String = ""
    func getCryptocurrencies(completion: @escaping ([Asset]) -> Void) {
        var assets: [Asset] = []
        Alamofire.request(urlForCryptocurrencies).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let json = JSON(responseData.result.value!)
                
                if let resultData = json.arrayObject {
                    self.resultsArray = resultData as! [[String:AnyObject]]
                }
                if self.resultsArray.count > 0 {
                    for result in self.resultsArray {
    
                        let asset: Asset = Asset (
                            id: result["id"] as! String,
                            name: result["name"] as! String,
                            symbol: result["symbol"] as! String,
                            imageURL: result["image"] as! String,
                            currentPrice: result["current_price"] as! Double,
                            marketCap: result["market_cap"] as! Double,
                            marketCapRank: result["market_cap_rank"] as! Int,
                            lastHigh: result["high_24h"] as! Double,
                            lastLow: result["low_24h"] as! Double,
                            priceChange: result["price_change_24h"] as! Double,
                            priceChangeInPercentage: result["price_change_percentage_24h"] as! Double,
                            supply: result["total_supply"] as? Int ?? 000,
                            cSupply: result["circulating_supply"] as? Double ?? 0.0,
                            ath: result["ath"] as! Double
                        )
                        assets.append(asset)
                    }
                    completion(assets)
                }
            }
        }
    }
    
    func getGlobalData(completion: @escaping (GlobalData) -> Void) {
        var marketCap: String = ""
        var btcDominance: String = ""
        var globalData: GlobalData = GlobalData(totalMarketCap: "0", btcDominance: "0")
        Alamofire.request(urlForGlobalData).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let json = JSON(responseData.result.value!)
                
                if let resultData = json.dictionaryObject {
                    self.globalDataResultsDict = resultData as! [String: [String:Any]]
                }
                if let data = self.globalDataResultsDict["data"] {
                    if let _ = data["total_market_cap"] {
                        let marketCapData = data["total_market_cap"] as! [String:Double]
                        let shrunkMarketCap: Double = marketCapData["usd"]!
                        marketCap = "$" + String(format: "%.2f",shrunkMarketCap/1000000000) + " Bn"
                    }
                    if let _ = data["market_cap_percentage"] {
                        let marketCapPercentageData = data["market_cap_percentage"] as! [String:Double]
                        btcDominance = String(format: "%.3f",marketCapPercentageData["btc"]!) + "%"
                    }
                }
            }
            let data: GlobalData = GlobalData(totalMarketCap: marketCap, btcDominance: btcDominance)
            globalData = data
            completion(globalData)
        }
        
    }
    
    func getCoinPrices(completion: @escaping ([AssetPriceList]) -> Void) {
        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let assets = appDelegate.homeViewController.assets
        var assetPriceLists: [AssetPriceList] = []
        self.urlForCoinPrices = "https://api.coingecko.com/api/v3/simple/price?ids=\(self.setIDParameterInURLForPrices(assets: assets))&vs_currencies=aud%2Cusd%2Cmxn%2Ceur%2Cgbp%2Ccad"
        Alamofire.request(urlForCoinPrices).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let json = JSON(responseData.result.value!)
                
                if let resultData = json.dictionaryObject {
                    self.coinPriceResultDict = resultData as! [String: [String:Double]]
                }
                for (coinName,priceList) in self.coinPriceResultDict {
                    let assetPriceList = AssetPriceList(
                        name: coinName,
                        aud: priceList["aud"]!,
                        usd: priceList["usd"]!,
                        mxn: priceList["mxn"]!,
                        gbp: priceList["gbp"]!,
                        eur: priceList["eur"]!,
                        cad: priceList["cad"]!)
                    assetPriceLists.append(assetPriceList)
                }
            }            
            completion(assetPriceLists)
        }
    }
    
    func setIDParameterInURLForPrices(assets: [Asset]) -> String {
        var idParameter = ""
        for asset in assets {
            idParameter.append("\(asset.id)%2C")
        }
        return idParameter
    }
    
}
