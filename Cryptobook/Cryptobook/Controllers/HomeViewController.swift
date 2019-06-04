//
//  FirstViewController.swift
//  Cryptobook
//
//  Created by Santiago  on 5/17/19.
//  Copyright © 2019 Santiago . All rights reserved.
//

//modules
import UIKit
import Alamofire
import SwiftyJSON


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    //outlets
    @IBOutlet weak var marketCapLabelHome: UILabel!
    @IBOutlet weak var BtcdLabelHome: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //variables
    var defaults = UserDefaults.standard
    let favoritesKeyString = "favorites_IDs"
    
    let networkingClient: NetworkingClient = NetworkingClient()
    
    var favoritesOnly: Bool = false
    var globalData: GlobalData = GlobalData(totalMarketCap: "0", btcDominance: "0")
    var assets: [Asset] = []
    var favorites: [Asset] = []
    var favoritesIDs: [String] = []
    
    let formatter = NumberFormatter()
    
    var refresher: UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.white
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
        ]
        let title = NSAttributedString(string: "Fetching Data...", attributes: attributes)
        refreshControl.attributedTitle = title
        refreshControl.addTarget(self, action: #selector(refreshCryptoData), for: .valueChanged)
        
        return refreshControl
    }
    
    //functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setFavorites()
        setupTableView()
        refreshCryptoData()
        tableView.reloadData()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favoritesOnly {
            return self.favorites.count
        }
        return self.assets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableCell", for: indexPath) as! HomeTableViewCell
        
        var asset: Asset {
            if favoritesOnly {
                return favorites[indexPath.row]
            }
            return assets[indexPath.row]
        }
        
        loadImageUsingUrlString(urlString: asset.imageURL, imageView: cell.cellImageView!)
        
        cell.nameLabel.text = asset.name
        cell.priceLabel.text = "$\(formatter.string(from: asset.currentPrice as NSNumber)!)"
        cell.symbolLabel.text = asset.symbol.capitalized
        cell.dayChangeLabel.text = String(format: "%.2f", asset.priceChangeInPercentage) + "%"
        
        if (asset.priceChangeInPercentage < 0.0) {
            cell.dayChangeLabel.textColor = UIColor.negativeRed
        } else if(asset.priceChangeInPercentage >= 0.0) {
            cell.dayChangeLabel.textColor = UIColor.positiveGreen
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let popup = sb.instantiateViewController(withIdentifier: "AssetPopUp") as! AssetViewController
        if favoritesOnly {
            popup.asset = favorites[indexPath.row]
        } else {
            popup.asset = assets[indexPath.row]
        }
        self.present(popup, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshCryptoData()
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    // Leading Actions in Row
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let asset = self.assets[indexPath.row]
        
        let favoriteAction = UIContextualAction(style: .normal, title: "Favorite") { (action, view, nil) in
            self.addToFavorites(asset: asset)
            tableView.reloadData()
            
        }
        
        favoriteAction.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [favoriteAction])
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        let inFavorites = self.favorites.contains { $0.id == asset.id }
        if inFavorites || favoritesOnly {
            return UISwipeActionsConfiguration(actions: [])
        }
        return swipeActionConfig
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if !favoritesOnly {
            return UISwipeActionsConfiguration(actions: [])
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            removeFromFavorites(asset: favorites[indexPath.row])
            setFavorites()
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            setFavorites()

            
        }
    }
    
    func setupTableView() {
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 4
        tableView.backgroundColor = UIColor.clear
        
        // Add Refresh Control to Table View
        tableView.refreshControl = refresher
    }
    
    @objc func refreshCryptoData() -> Void {
        networkingClient.getGlobalData(completion: self.setGlobalData)
        networkingClient.getCryptocurrencies(completion: self.setAssets)
    }
    
    func setAssets(assets: [Asset]) -> Void {
        self.assets = assets
        setFavorites()
        let deadline = DispatchTime.now() + .milliseconds(750)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.tableView.refreshControl!.endRefreshing()
        }
        self.tableView.reloadData()
    }
    
    func setFavorites() {
        favorites = []
        favoritesIDs = defaults.array(forKey: favoritesKeyString) as? [String] ?? []
        for id in favoritesIDs {
            if let index = assets.firstIndex(where: { $0.id == id }) {
                self.favorites.append(assets[index])
            }
        }
        
    }
    
    func setGlobalData(gData: GlobalData) -> Void {
        self.globalData = gData
        marketCapLabelHome.text = self.globalData.totalMarketCap
        BtcdLabelHome.text = self.globalData.btcDominance
    }
    
    func addToFavorites(asset: Asset) {
        favoritesIDs.append(asset.id)
        defaults.set(favoritesIDs, forKey: favoritesKeyString)
    }
    func removeFromFavorites(asset: Asset) {
        var toRemoveIndex = 0
        for (index,id) in favoritesIDs.enumerated() {
            if asset.id == id {
                toRemoveIndex = index
            }
        }
        favoritesIDs.remove(at: toRemoveIndex)
        defaults.set(favoritesIDs, forKey: favoritesKeyString)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
}


