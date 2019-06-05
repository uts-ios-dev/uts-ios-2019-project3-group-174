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
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var totalLabel: UILabel!
    
    //variable for the API
    let networkingClient: NetworkingClient = NetworkingClient()
    
    //variables
    var currentTextField = UITextField()
    var pickerView = UIPickerView()
    var cryptoSelected : String?
    var exchangeSelected : String?
    var assetPriceLists = [] as [AssetPriceList]
    var exchangeList = ["AUD", "USD", "MXN", "GBP", "CAD", "EUR"]
    
    //functions
    override func viewDidLoad() {
        super.viewDidLoad()
        amountTextField.delegate = self
        setUpTextField()
        setupTextFieldListeners()
        
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.hideKeyboard))
        
        self.view.addGestureRecognizer(tapRecognizer)
        
    }
    //Deinitialization of keyboard
    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    //get coin prices from the API
    override func viewWillAppear(_ animated: Bool) {
        networkingClient.getCoinPrices(completion: setPrices)
    }
    
    //set the list of the pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //returns the size of the arrays
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if currentTextField == cryptoPicker {
            return assetPriceLists.count
        } else if currentTextField == exchangePicker {
            return exchangeList.count
        } else {
            return 0
        }
    }
    //show the options in the pickerView
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if currentTextField == cryptoPicker {
            return assetPriceLists[row].name.capitalized
        } else if currentTextField == exchangePicker {
            return exchangeList[row]
        } else {
            return ""
        }
    }
    //sets the selected option and calculates the price
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if currentTextField == cryptoPicker {
            cryptoPicker.text = assetPriceLists[row].name.capitalized
            self.view.endEditing(true)
            recalculateTotal()
        } else if currentTextField == exchangePicker {
            exchangePicker.text = exchangeList[row]
            self.view.endEditing(true)
            recalculateTotal()
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
    //when it finishes editing calculates the price
    @IBAction func onEditingChanged(_ sender: Any) {
       recalculateTotal()
    }
    
    //sets the price to be calculated and recalculate value
    func setPrices(assetPriceLists: [AssetPriceList]) -> Void {
        self.assetPriceLists = assetPriceLists
        recalculateTotal()
    }
    //add done button to the textField
    func setUpTextField() {
        amountTextField.addDoneButtonToKeyboard()
    }
    
    //manages amount textField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // User pressed the delete-key to remove a character, this is always valid, return true to allow change
        
        if amountTextField.isEditing {
            if string.isEmpty { return true }
            let currentText = textField.text ?? ""
            let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)
            return replacementText.isValidDouble(maxDecimalPlaces: 5)
        }
        return false
    }
    //add event listeners to the textFields
    func setupTextFieldListeners() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    //adjust the keyboard in every device
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        if amountTextField.isEditing {
            if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
                view.frame.origin.y = -keyboardRect.height
            } else {
                view.frame.origin.y = 0
            }
        }
    }
    //hides keyboard in the amount textField
    @objc
    func hideKeyboard() {
        amountTextField.resignFirstResponder()
    }
    //recalculates value depending on selections
    func recalculateTotal() {
        var amount : Double {
            if amountTextField.text!.isEmpty {
                return 0.0
            }
            return Double(amountTextField.text!) as! Double
        }
        let cryptoChosen = cryptoPicker.text!.lowercased()
        let currencyChosen = exchangePicker.text!.lowercased()
        let index = assetPriceLists.firstIndex(where: { $0.name == cryptoChosen })!
        var total = 0.0
        switch currencyChosen {
        case "usd":
            total = assetPriceLists[index].usd * amount
        case "mxn":
            total = assetPriceLists[index].mxn * amount
        case "aud":
            total = assetPriceLists[index].aud * amount
        case "gbp":
            total = assetPriceLists[index].gbp * amount
        case "cad":
            total = assetPriceLists[index].cad * amount
        case "eur":
            total = assetPriceLists[index].eur * amount
        default:
            total = 0.0
        }
        totalLabel.text = "\(currencyChosen.uppercased()) \(String(format: "%.2f", total))"
        
    }
    
}
