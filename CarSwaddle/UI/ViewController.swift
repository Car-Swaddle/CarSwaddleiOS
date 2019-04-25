//
//  ViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/7/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import Store
import CarSwaddleNetworkRequest

class ViewController: UIViewController {
    
    private var service = AutoServiceService(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = SignUpViewController.viewControllerFromStoryboard()
        
        navigationController?.pushViewController(vc.inNavigationController(), animated: false)
        
//        let user = User(context: store.mainContext)
//        user.identifier = "someuniqueID"
//        user.firstName = "Kyle"
//        user.lastName = "Kendall"
//        user.phoneNumber = "801-960-5212"
//        store.mainContext.persist()
        
//        service.hitServer { data, error in
//            print("came back: \(data), error: \(error)")
//            guard let data = data else {
//                return
//            }
//            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
//                return
//            }
//
//            print("json: \(json)")
//        }
        
        
//        service.postServer { data, error in
//            guard let data = data else {
//                return
//            }
//            guard let json = (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any?]) else {
//                if let string = String(data: data, encoding: .utf8) {
//                    print(string)
//                }
//                return
//            }
//
//            print("json: \(json)")
//        }
        
    }


}

