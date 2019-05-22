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
    
    let networkingClient = NetworkingClient()
    let formatter = NumberFormatter()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        networkingClient.getCryptocurrencies(table: tableView)
        networkingClient.getGlobalData(label1: marketcapLabel, label2: btcdLabel)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networkingClient.resultsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableCell", for: indexPath) as! HomeTableViewCell
        
        let changePercentage = networkingClient.resultsArray[indexPath.row]["price_change_percentage_24h"] as! Double
        let currentPrice = networkingClient.resultsArray[indexPath.row]["current_price"] as! Double
        let formattedPrice = formatter.string(from: currentPrice as NSNumber)!
        
        cell.nameLabel.text = (networkingClient.resultsArray[indexPath.row]["name"] as! String)
        cell.symbolLabel.text = (networkingClient.resultsArray[indexPath.row]["symbol"] as! String).capitalized
        
        if (changePercentage < 0.0) {
            cell.dayChangeLabel.textColor = hexStringToUIColor(hex: "#F54D4E")
        } else if(changePercentage >= 0.0) {
            cell.dayChangeLabel.textColor = hexStringToUIColor(hex: "#09C114")
        }
        cell.dayChangeLabel.text = String(format: "%.2f",changePercentage) + "%"
        cell.priceLabel.text = "$" + formattedPrice
        
        return cell
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
        tableView.refreshControl!.addTarget(self, action: #selector(refreshCryptoData(_:)), for: .valueChanged)
        tableView.refreshControl!.tintColor = UIColor.white
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Asset Data...")
    }
    
    @objc private func refreshCryptoData(_ sender: Any) {
        // Fetch Weather Data
        networkingClient.getCryptocurrencies(table: tableView)
        networkingClient.getGlobalData(label1: marketcapLabel, label2: btcdLabel)
        
        tableView.refreshControl!.endRefreshing()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

