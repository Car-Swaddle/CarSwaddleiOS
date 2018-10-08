//
//  CreateServiceCell.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/23/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import Store
//import CarSwaddleUI


typealias CreateServiceCell = (UITableViewCell & AutoServiceConfigurable)

protocol AutoServiceConfigurable: class {
    func configure(with service: AutoService)
}
