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
    private let refreshControl = UIRefreshControl()
    
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
            print(self.favoritesIDs)
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
            self.favorites.remove(at: indexPath.row)
            removeFromFavorites(asset: assets[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    
    func setupTableView() {
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 4
        tableView.backgroundColor = UIColor.clear
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        tableView.refreshControl!.addTarget(self, action: #selector(refreshCryptoDataAction(_:)), for: .valueChanged)
        tableView.refreshControl!.tintColor = UIColor.white
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Asset Data...")
    }
    
    @objc private func refreshCryptoDataAction(_ sender: Any) {
        networkingClient.getGlobalData(completion: self.setGlobalData)
        networkingClient.getCryptocurrencies(completion: self.setAssets)
        tableView.refreshControl!.endRefreshing()
    }
    
    func refreshCryptoData() -> Void {
        networkingClient.getGlobalData(completion: self.setGlobalData)
        networkingClient.getCryptocurrencies(completion: self.setAssets)
    }
    
    func setAssets(assets: [Asset]) -> Void {
        self.assets = assets
        setFavorites()
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

