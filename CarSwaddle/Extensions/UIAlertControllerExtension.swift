//
//  UIAlertControllerExtension.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit


private let cancelButtonTitle = NSLocalizedString("Cancel", comment: "Action to cancel on an alert")
private let okayButtonTitle = NSLocalizedString("Okay", comment: "Action to okay on an alert")

extension UIAlertAction {
    
    static func cancelAction(_ handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: handler)
    }
    
    class func okayAction(_ handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: okayButtonTitle, style: .default, handler: handler)
    }
    
}



extension UIAlertController {
    
    func addCancelAction(_ handler: ((UIAlertAction) -> Void)? = nil) {
        self.addAction( UIAlertAction.cancelAction(handler) )
    }
    
    func addOkayAction(_ handler: ((UIAlertAction) -> Void)? = nil) {
        self.addAction( UIAlertAction.okayAction(handler) )
    }
    
}
