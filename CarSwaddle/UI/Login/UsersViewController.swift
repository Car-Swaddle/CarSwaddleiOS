//
//  UsersViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleNetworkRequest

class UsersViewController: UIViewController {

    private let userService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        userService.getUsers(offset: 0, limit: 1) { (json, error) in
        userService.getCurrentUser { json, error in
            print(json ?? "")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
