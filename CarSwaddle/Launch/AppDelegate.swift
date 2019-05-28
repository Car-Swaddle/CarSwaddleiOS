//
//  AppDelegate.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/7/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CoreData
import Stripe
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupLibraries()
        
        _ = pushNotificationController
        store.mainContext.persist()
                
        navigator.setupWindow()
        
        return true
    }
    
    
    private func setupLibraries() {
        FirebaseApp.configure()
        STPPaymentConfiguration.shared().publishableKey = stripePublishableKey
        STPPaymentConfiguration.shared().appleMerchantIdentifier = appleMerchantIdentifier
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        pushNotificationController.didRegister(withDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        pushNotificationController.didFailToRegisterForRemoteNotifications(with: error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        pushNotificationController.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return UserActivityHandler.shared.handle(userActivity: userActivity)
    }

}

