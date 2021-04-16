//
//  Intercom.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/16/21.
//  Copyright © 2021 CarSwaddle. All rights reserved.
//

import Foundation
import FirebaseDynamicLinks
import Authentication
import CarSwaddleData
import CarSwaddleStore
import CoreData
import CarSwaddleNetworkRequest
import Branch


/// Short access to shared Intercom instance
public let intercom = Intercom.shared


private let resetPasswordPath = "/car-swaddle/reset-password"
private let resetTokenQueryItemName = "resetToken"

private let affiliateDomain = "affiliate.carswaddle.com"
private let goDomain = "go.carswaddle.com"
private let appDomain = "app.carswaddle.com"

/// Inter app communications
/// This should handle all communications in and out of the app
public class Intercom {
    
    public static let shared = Intercom()
    
    public let goCarSwaddleNavigation: URLNavigation = URLNavigation(baseURL: "https://" + goDomain)
    public let affiliateCarSwaddleNavigation = URLNavigation(baseURL: "https://" + affiliateDomain)
    
    private let userNetwork = UserNetwork(serviceRequest: serviceRequest)
    
    // MARK: - Referrer
    
    public func wipeReferrerID() {
        referrerID = nil
    }
    
    @UserDefault(key: "referrerID")
    public var referrerID: String?
    
    // MARK: - Dynamic Links
    
    func setup() {
        if let serverType = Tweak.currentDomainServerType() {
            switch serverType {
            case .local, .staging:
                Branch.setUseTestBranchKey(true)
            case .production:
                Branch.setUseTestBranchKey(false)
            }
        }
    }
    
    private func handleReferrerIDFromDeepLink(referrerID: String) {
        if AuthController().isLoggedIn {
            // update referrer for current user
            store.privateContext { context in
                let updateUser = UpdateUser(referrerID: referrerID)
                self.userNetwork.update(user: updateUser, in: context) { userObjectID, error in
                    print("updated")
                }
            }
        } else {
            // store on disk and on sign up check if a referrer is stored to be sent up
            self.referrerID = referrerID
        }
    }
    
    func registerForDynamicLinks(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        Branch.getInstance().initSession(launchOptions: launchOptions) { [weak self] parameters, error in
            guard let self = self else { return }
            if let referrerID = parameters?["referrerId"] as? String {
                self.handleReferrerIDFromDeepLink(referrerID: referrerID)
            }
        }
    }
    
    func didReceiveRemoteNotification(userInfo: [AnyHashable: Any]) {
        Branch.getInstance().handlePushNotification(userInfo)
    }
    
    func handleOpenURL(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Branch.getInstance().application(app, open: url, options: options)
    }
    
    func handleUserActivity(_ userActivity: NSUserActivity) -> Bool {
        Branch.getInstance().continue(userActivity)
    }
    
}
