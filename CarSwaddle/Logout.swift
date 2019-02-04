//
//  Logout.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 2/1/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import Foundation
import Authentication
import CarSwaddleData

public let logout = Logout()

final public class Logout {
    
    public init() {
        
    }
    
    private let auth = Auth(serviceRequest: serviceRequest)
    
    public func logout(completion: @escaping () -> Void = {}) {
        auth.logout(deviceToken: pushNotificationController.getDeviceToken()) { error in
            DispatchQueue.main.async {
                finishTasksAndInvalidate {
                    try? store.destroyAllData()
                    try? profileImageStore.destroy()
                    AuthController().removeToken()
                    pushNotificationController.deleteDeviceToken()
                    DispatchQueue.main.async {
                        navigator.navigateToLoggedOutViewController()
                    }
                }
            }
        }
    }
    
}
