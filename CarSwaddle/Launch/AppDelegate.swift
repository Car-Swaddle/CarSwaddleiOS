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
import Branch



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupLibraries()
        
        intercom.registerForDynamicLinks(launchOptions: launchOptions)
        
        _ = pushNotificationController
        store.mainContext.persist()
        
        navigator.setupWindow()
        
        return true
    }
    
    
    private func setupLibraries() {
        intercom.setup()
        FirebaseApp.configure()
        tracker.configure()
        STPAPIClient.shared().publishableKey = stripePublishableKey
        STPPaymentConfiguration.shared().appleMerchantIdentifier = appleMerchantIdentifier
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        pushNotificationController.didRegister(withDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        pushNotificationController.didFailToRegisterForRemoteNotifications(with: error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        intercom.didReceiveRemoteNotification(userInfo: userInfo)
        pushNotificationController.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    open func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return intercom.handleOpenURL(app, open: url, options: options)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return intercom.handleUserActivity(userActivity)
    }

}
