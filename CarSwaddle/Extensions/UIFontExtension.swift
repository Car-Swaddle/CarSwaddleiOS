//
//  UIFontExtension.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit


//enum FontType: String {
//    case bold = "Montreal-Bold"
//    //    case boldItalic = "OpenSans-BoldItalic"
//    //    case condLight = "OpenSans-CondLight"
//    //    case extraBold = "OpenSans-ExtraBold"
//    //    case extraBoldItalic = "OpenSans-ExtraBoldItalic"
//    //    case light = "OpenSans-Light"
//    //    case lightItalic = "OpenSans-LightItalic"
//    case regular = "Montreal-Regular"
//    //    case semibold = "OpenSans-Semibold"
//    //    case semiboldItalic = "OpenSans-SemiboldItalic"
//}
//
//// Montreal-Regular Montreal-Bold
//
//private let prominentFontSize: CGFloat = 18.0
//
//extension UIFont {
//
//    class func appFontWithSize(_ size: CGFloat, type: FontType = .regular) -> UIFont! {
//        return UIFont(name: type.rawValue, size: size)
//    }
//
//    static var prominentFont: UIFont {
//        return appFontWithSize(prominentFontSize, type: .bold)
//    }
//
//}


extension UIFont {
    
    class func printAllFontNames() {
        let fontFamilies = UIFont.familyNames
        for font in fontFamilies {
            print("fontFamily: \(font), font names: \(UIFont.fontNames(forFamilyName: font))")
        }
    }
    
}
