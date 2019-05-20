//
//  UIColor+Extensions.swift
//  YomCalendar-iOS
//
//  Created by Guillaume Bellue on 20/05/2019.
//  Copyright © 2019 Yom. All rights reserved.
//

import UIKit

extension UIColor {
    public var hexString: String {
        var colorRFloat: CGFloat = 0.0
        var colorGFloat: CGFloat = 0.0
        var colorBFloat: CGFloat = 0.0
        var colorAFloat: CGFloat = 0.0
        getRed(&colorRFloat, green: &colorGFloat, blue: &colorBFloat, alpha: &colorAFloat)

        let colorRInt: UInt8 = UInt8(255.0 * colorRFloat)
        let colorGInt: UInt8 = UInt8(255.0 * colorGFloat)
        let colorBInt: UInt8 = UInt8(255.0 * colorBFloat)

        return NSString(format: "%02x%02x%02x", colorRInt, colorGInt, colorBInt) as String
    }

    public convenience init(hexString: String, alpha: CGFloat = 1) {
        var colorR: CGFloat = 0.0
        var colorG: CGFloat = 0.0
        var colorB: CGFloat = 0.0

        if 9 > hexString.utf16.count {
            let scanner: Scanner = Scanner(string: hexString)
            scanner.charactersToBeSkipped = NSCharacterSet(charactersIn: "#") as CharacterSet

            var hexInt: UInt32 = 0
            if scanner.scanHexInt32(&hexInt) {
                colorR = CGFloat(((hexInt & 0xFF0000) >> 16)) / 255.0
                colorG = CGFloat(((hexInt & 0xFF00) >> 8)) / 255.0
                colorB = CGFloat(((hexInt & 0xFF) >> 0)) / 255.0
            }
        }

        self.init(red: colorR, green: colorG, blue: colorB, alpha: alpha)
    }
}
