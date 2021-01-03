//
//  StartViewController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/22/20.
//  Copyright © 2020 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import CarSwaddleStore
import Authentication

protocol StartViewControllerDelegate: AnyObject {
    func didDetermineStartPath(startPath: StartViewController.StartPath)
}

class StartViewController: UIViewController, StoryboardInstantiating {
    
    enum StartPath {
        case loggedIn
        case loggedOut
    }
    
    weak var delegate: StartViewControllerDelegate?
    
    private var userService: UserNetwork = UserNetwork(serviceRequest: serviceRequest)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.privateContext { [weak self] context in
            self?.userService.requestCurrentUser(in: context) { objectID, error in
                if let objectID = objectID,
                   let user = context.object(with: objectID) as? User {
                    User.setCurrentUserID(user.identifier)
                }
                if AuthController().token == nil || error != nil {
                    AuthController().removeToken()
                    self?.delegate?.didDetermineStartPath(startPath: .loggedOut)
                } else {
                    self?.delegate?.didDetermineStartPath(startPath: .loggedIn)
                }
            }
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
