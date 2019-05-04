//
//  TextInputCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/31/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI

class TextInputCell: UITableViewCell, NibRegisterable {
    
    @IBOutlet weak var labeledTextField: LabeledTextField!
    
    var textDidChange: () -> Void = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        labeledTextField.textFieldFont = UIFont.appFont(type: .regular, size: 17)
        
        selectionStyle = .none
        
        labeledTextField.textField.addTarget(self, action: #selector((TextInputCell.textChanged)), for: .editingChanged)
    }
    
    @objc private func textChanged() {
        textDidChange()
    }
    
}
