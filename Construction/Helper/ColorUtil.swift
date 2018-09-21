////
//  ColorUtil.swift
//  Nuooly
//
//  Created by CodeX on 23/02/2018.
//  Copyright © 2018 Dev_iOS. All rights reserved.
//

import UIKit


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    static var appBlueColor = UIColor(rgb: 0x4980FF)
    static let primaryColor = UIColor(rgb: 0xF4511E)
    static let accentColor = UIColor(rgb: 0xF4511E)
    static let appTintColor = UIColor(red: 28/255, green: 144/255, blue: 91/255, alpha: 1.0)
    
}
