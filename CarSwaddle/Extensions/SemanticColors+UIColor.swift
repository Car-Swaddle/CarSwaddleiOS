//
//  SemanticColors+UIColor.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 10/19/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import Foundation

/// Semantic Colors. Developer should default to these colors, if they don't exist, look at the color scales, then hex/255
extension UIColor {
    
    // MARK: - Action
    
    static let action = UIColor(named: "action")!
    static let secondaryAction = UIColor(named: "secondaryAction")!
    
    // MARK: - Background
    
    static let background = UIColor(named: "background")!
    static let secondaryBackground = UIColor(named: "secondaryBackground")!
    static let tertiaryBackground = UIColor(named: "tertiaryBackground")!
    
    // MARK: - Content
    
    static let content = UIColor(named: "content")!
    static let secondaryContent = UIColor(named: "secondaryContent")!
    static let tertiaryContent = UIColor(named: "tertiaryContent")!
    
    static let contentBehindContent = UIColor(named: "contentBehindContent")!
    
    static let brand = UIColor(named: "brand")!
    static let danger = UIColor(named: "danger")!
    static let success = UIColor(named: "success")!
    static let warning = UIColor(named: "warning")!
    
    // MARK: - Text
    
    static let disabledText = UIColor(named: "disabledText")!
    static let secondaryText = UIColor(named: "secondaryText")!
    static let tertiaryText = UIColor(named: "tertiaryText")!
    static let text = UIColor(named: "text")!
    static let inverseText = UIColor(named: "inverseText")!
    static let inverseTextSecondary = UIColor(named: "inverseTextSecondary")!
    
}
