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


/// Short access to shared Intercom instance
public let intercom = Intercom.shared


private let resetPasswordPath = "/car-swaddle/reset-password"
private let resetTokenQueryItemName = "resetToken"

private let affiliateDomain = "affiliate.carswaddle.com"
private let goDomain = "go.carswaddle.com"

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
    
    @UserDefault(key: "vanityID")
    public var vanityID: String?
    
    // MARK: - Dynamic Links
    
    private func dynamicLink(fromCustomSchemeURL url: URL) -> URL? {
        return DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url)?.url
    }
    
    private func dynamicLink(fromUniversalLink url: URL, completion: @escaping (_ dynamicLink: URL?) -> Void) {
        DynamicLinks.dynamicLinks().handleUniversalLink(url) { dynamiclink, error in
            completion(dynamiclink?.url)
        }
    }
    
    public func handleOpenURL(url: URL) -> Bool {
        if let dynamicLink = self.dynamicLink(fromCustomSchemeURL: url) {
            return handleDynamicLink(url: dynamicLink)
        } else {
            return false
        }
    }
    
    public func handle(userActivity: NSUserActivity) -> Bool {
        guard let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return false
        }
        
        if let firstQueryItem = components.queryItems?.first, components.path == resetPasswordPath && firstQueryItem.name == resetTokenQueryItemName,
            let resetToken = firstQueryItem.value {
            navigator.showEnterNewPasswordScreen(resetToken: resetToken)
            return true
        } else {
            dynamicLink(fromUniversalLink: url) { [weak self] dynamiclink in
                guard let link = dynamiclink else { return }
                self?.handleDynamicLink(url: link)
            }
            return false
        }
    }
    
    @discardableResult
    private func handleDynamicLink(url: URL) -> Bool {
        guard let host = url.host else { return false }
        switch host {
        case affiliateDomain:
            return handleAffilateLink(url: url)
        default:
            return false
        }
    }
    
    private func handleAffilateLink(url: URL) -> Bool {
        guard let referrerID = url.queryParameters?["referrerID"],
              let vanityID = url.queryParameters?["vanityID"] else { return false }
        
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
            self.vanityID = vanityID
        }
        return true
    }
    
}
