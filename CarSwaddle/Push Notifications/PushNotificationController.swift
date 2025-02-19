//
//  PushNotificationController.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 12/7/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UserNotifications
import UIKit
import CarSwaddleData
import Branch


public let pushNotificationController = PushNotificationController()

private let deviceTokenKey = "deviceTokenKey"

public class PushNotificationController: NSObject {
    
    private let userNetwork: UserNetwork = UserNetwork(serviceRequest: serviceRequest)
    
    public override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    public func didRegister(withDeviceToken deviceToken: Data) {
        let deviceTokenString = self.deviceTokenString(fromDeviceTokenData: deviceToken)
        storeDeviceToken(deviceToken: deviceTokenString)
        store.privateContext { [weak self] context in
            self?.userNetwork.update(firstName: nil, lastName: nil, phoneNumber: nil, token: deviceTokenString, timeZone: nil, referrerID: nil, in: context) { user, error in
                print("user updated")
            }
        }
    }
    
    public func didFailToRegisterForRemoteNotifications(with error: Error) {
        print("Failed to register remote notifications: \(error)")
    }
    
    public func didReceiveRemoteNotification(userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("got remote notification: \(userInfo)")
        completionHandler(.newData)
    }
    
    public func requestPermission() {
        let options: UNAuthorizationOptions = [.badge, .alert, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if error == nil && granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    private func deviceTokenString(fromDeviceTokenData data: Data) -> String {
        return data.reduce("", {$0 + String(format: "%02X", $1)})
    }
    
    public func getDeviceToken() -> String? {
        return UserDefaults.standard.value(forKey: deviceTokenKey) as? String
    }
    
    public func deleteDeviceToken() {
        UserDefaults.standard.setValue(nil, forKey: deviceTokenKey)
    }
    
    private func storeDeviceToken(deviceToken: String) {
        UserDefaults.standard.setValue(deviceToken, forKey: deviceTokenKey)
    }
    
    private func handleInteraction(interactionInfo: [AnyHashable: Any]) {
        guard let remoteNotification = RemoteNotification(userInfo: interactionInfo) else {
            return
        }
        switch remoteNotification {
        case .mechanicRating(let rating):
            navigator.showRatingAlertFor(autoServiceID: rating.autoServiceID)
        case .reminder(let reminder):
            navigator.showAutoService(autoServiceID: reminder.autoServiceID)
        case .userDidRate(let userDidRate):
            navigator.showAutoService(autoServiceID: userDidRate.autoServiceID)
        case .autoServiceWasUpdated(let autoServiceWasUpdated):
            navigator.showAutoService(autoServiceID: autoServiceWasUpdated.autoServiceID)
        }
    }
    
}

extension PushNotificationController: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        print("open settings for")
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("did receive response")
        completionHandler()
        let userInfo = response.notification.request.content.userInfo
        handleInteraction(interactionInfo: userInfo)
        completionHandler()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("will present")
        completionHandler([.alert, .badge, .sound])
    }
    
}
