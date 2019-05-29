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
