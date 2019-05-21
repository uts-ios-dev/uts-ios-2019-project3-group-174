//
//  FirstViewController.swift
//  Cryptobook
//
//  Created by Santiago  on 5/17/19.
//  Copyright © 2019 Santiago . All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var marketcapLabel: UILabel!
    @IBOutlet weak var btcdLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

