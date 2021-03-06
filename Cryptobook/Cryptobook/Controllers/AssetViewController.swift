//
//  AssetViewController.swift
//  Cryptobook
//
//  Created by Santiago  on 6/1/19.
//  Copyright © 2019 Santiago . All rights reserved.
//

import UIKit

class AssetViewController: UIViewController {
    @IBOutlet weak var cryptoLogoImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var percentageChangeLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var marketCapLabel: UILabel!
    @IBOutlet weak var currentSupplyLabel: UILabel!
    @IBOutlet weak var totalSupplyLabel: UILabel!
    @IBOutlet weak var allTimeHighLabel: UILabel!
    
    
    var asset: Asset = Asset(id: "", name: "", symbol: "", imageURL: "", currentPrice: 0.0, marketCap: 0.0 , marketCapRank: 0, lastHigh: 0.0, lastLow: 0.0, priceChange: 0.0, priceChangeInPercentage: 0.0, supply: 1, cSupply: 0.0, ath: 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // GestureRecognizer to dismiss coin popups on drag
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onDrag)))
        setUpData()
    }
    
    // fill the TableView with the assets data
    func setUpData() {
        nameLabel.text = asset.name
        symbolLabel.text = asset.symbol.uppercased()
        rankLabel.text = "#\(asset.marketCapRank)"
        priceLabel.text = "USD \(asset.currentPrice)"
        percentageChangeLabel.text = String(format: "%.2f", asset.priceChangeInPercentage) + "%"
        // change text color if percentage is positive or negative
        if (asset.priceChangeInPercentage < 0.0) {
            percentageChangeLabel.textColor = UIColor.negativeRed
        } else if (asset.priceChangeInPercentage >= 0.0) {
            percentageChangeLabel.textColor = UIColor.positiveGreen
        }
        lowLabel.text = "\(asset.lastLow)"
        highLabel.text = "\(asset.lastHigh)"
        marketCapLabel.text = "$\(asset.marketCap)"
        // nil handling on API calls
        if asset.cSupply != 0.0 {
            currentSupplyLabel.text = "\(asset.cSupply)"
        } else {currentSupplyLabel.text = "N/A"}
        
        if asset.supply != 0 {
            totalSupplyLabel.text = "\(asset.supply)"
        } else {totalSupplyLabel.text = "N/A"}
        allTimeHighLabel.text = "$\(asset.ath)"
        loadImageUsingUrlString(urlString: asset.imageURL, imageView: cryptoLogoImage)
    }
    
    @objc
    func onDrag(sender: Any) {
        dismiss(animated: true)
    }
    
    
}
