//
//  Extensions.swift
//  Cryptobook
//
//  Created by Santiago  on 5/22/19.
//  Copyright © 2019 Santiago . All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static let positiveGreen = hexStringToUIColor(hex: "#09C114")
    static let negativeRed = hexStringToUIColor(hex: "#F54D4E")
}

extension Double {
    private static var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter
    }()
    
    var delimiter: String {
        return Double.numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}

extension Int {
    private static var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter
    }()
    
    var delimiter: String {
        return Int.numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}

extension String {
    func isValidDouble(maxDecimalPlaces: Int) -> Bool {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        let decimalSeparator = formatter.decimalSeparator ?? "."
        if formatter.number(from: self) != nil {
            let split = self.components(separatedBy: decimalSeparator)
            let digits = split.count == 2 ? split.last ?? "" : ""
            return digits.count <= maxDecimalPlaces
        }
        return false
    }
}

extension UITextField{
    
    func addDoneButtonToKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(onDone))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    @objc func onDone() {
        self.resignFirstResponder()
    }
}

// global Functions
func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

let imageCache = NSCache<NSString, UIImage>()

func loadImageUsingUrlString(urlString: String, imageView: UIImageView) {
    let url = URL(string: urlString)
    if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
        imageView.image = imageFromCache
        return
    }
    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
        if error != nil {
            print(error!)
            return
        }
        DispatchQueue.main.async {
            if let image = UIImage(data: data!) {
                imageView.image = image
                imageCache.setObject(UIImage(data: data!)!, forKey: urlString as NSString)
            }
        }
    }).resume()
    
}

