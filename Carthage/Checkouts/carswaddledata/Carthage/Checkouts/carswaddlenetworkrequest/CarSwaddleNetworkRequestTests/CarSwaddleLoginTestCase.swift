//
//  CarSwaddleNetworkRequestTests.swift
//  CarSwaddleNetworkRequestTests
//
//  Created by Kyle Kendall on 9/17/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleNetworkRequest
import Authentication

class CarSwaddleLoginTestCase: XCTestCase {
    
    private let authService = AuthService(serviceRequest: serviceRequest)
    
    override func setUp() {
        
        // Remove the token for the first test case
        DispatchQueue.once(token: "SomeString") {
            AuthController().removeToken()
        }
        
        loginIfNeeded()
    }
    
    private func loginIfNeeded() {
        guard authentication.token == nil else { return }
        
        let exp = expectation(description: "\(#function)\(#line)")
        authService.mechanicLogin(email: "k@k.com", password: "password") { [weak self] json, token, error in
            if let token = token {
                authentication.setToken(token)
                exp.fulfill()
            } else {
                self?.authService.mechanicSignUp(email: "k@k.com", password: "password") { json, token, error in
                    if let token = token {
                        authentication.setToken(token)
                    }
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}



#if targetEnvironment(simulator)
private let domain = "127.0.0.1"
#else
private let domain = "Kyles-MacBook-Pro.local"
#endif

//private let domain = "127.0.0.1"

public let serviceRequest: Request = {
    let request = Request(domain: domain)
    request.port = 3000
    request.timeout = 15
    request.defaultScheme = .http
    return request
}()

private let authentication = AuthController()

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block: () -> Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) { return }
        _onceTracker.append(token)
        block()
    }
}
