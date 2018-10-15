//
//  UIAlertControllerExtensions.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 10/8/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit


private let cancelButtonTitle = NSLocalizedString("Cancel", comment: "Action to cancel on an alert")
private let okayButtonTitle = NSLocalizedString("Okay", comment: "Action to okay on an alert")

public extension UIAlertAction {
    
    public static func cancelAction(_ handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: handler)
    }
    
    public static func okayAction(_ handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: okayButtonTitle, style: .default, handler: handler)
    }
    
}



public extension UIAlertController {
    
    public func addCancelAction(_ handler: ((UIAlertAction) -> Void)? = nil) {
        self.addAction( UIAlertAction.cancelAction(handler) )
    }
    
    public func addOkayAction(_ handler: ((UIAlertAction) -> Void)? = nil) {
        self.addAction( UIAlertAction.okayAction(handler) )
    }
    
}


