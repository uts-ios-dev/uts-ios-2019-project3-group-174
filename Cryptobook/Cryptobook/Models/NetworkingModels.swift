//
//  CryptocurrencyModel.swift
//  Cryptobook
//
//  Created by Santiago  on 5/24/19.
//  Copyright © 2019 Santiago . All rights reserved.
//

import Foundation

struct Asset {
    let id : String
    let name : String
    let symbol : String
    let imageURL : String
    let currentPrice : Double
    let marketCap : Double
    let marketCapRank : Int
    let lastHigh : Double
    let lastLow : Double
    let priceChange : Double
    let priceChangeInPercentage : Double
    let supply : Int
    let cSupply : Double
    let ath : Double
}

struct GlobalData {
    let totalMarketCap : String
    let btcDominance: String
}

struct AssetPriceList {
    let name : String
    let aud : Double
    let usd : Double
    let mxn : Double
    let gbp : Double
    let eur : Double
    let cad : Double
}
