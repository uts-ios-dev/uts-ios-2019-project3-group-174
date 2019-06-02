//
//  ConversionViewController.swift
//  Cryptobook
//
//  Created by Esteban Torres Alarcon on 6/1/19.
//  Copyright © 2019 Santiago . All rights reserved.
//

import UIKit

class ConversionViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    //outlets
    
    @IBOutlet weak var cryptoPicker: UITextField!
    @IBOutlet weak var exchangePicker: UITextField!
    //var
    var currentTextField = UITextField()
    var pickerView = UIPickerView()
    var cryptoSelected : String?
    var exchangeSelected : String?
    var cryptoList = [] as [String]
    var exchangeList = [] as [String]
    
    //functions
    override func viewDidLoad() {
        super.viewDidLoad()
        cryptoPicker.tag = 1
        exchangePicker.tag = 2
        cryptoList = ["Bitcoin", "Dash", "Ripple", "Monero"]
        exchangeList = ["AUD", "MXN", "USD"]
        //setDoneButtonPickerView()
    }
    //fromPicker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //returns the size of the arrays
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if currentTextField == cryptoPicker {
            return cryptoList.count
        } else if currentTextField == exchangePicker {
            return exchangeList.count
        } else {
            return 0
        }
    }
    //cryptoPicker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if currentTextField == cryptoPicker {
            return cryptoList[row]
        } else if currentTextField == exchangePicker {
            return exchangeList[row]
        } else {
            return ""
        }
    }
    //cryptoPicker
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if currentTextField == cryptoPicker {
            cryptoPicker.text = cryptoList[row]
            self.view.endEditing(true)
        } else if currentTextField == exchangePicker {
            exchangePicker.text = exchangeList[row]
            self.view.endEditing(true)
        }
    }
    //Text Field Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        currentTextField = textField
        if currentTextField == cryptoPicker {
            currentTextField.inputView = pickerView
        } else if currentTextField == exchangePicker {
            currentTextField.inputView = pickerView
        }
        
    }
}
