//
//  Auth.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

//import Foundation
//import CarSwaddleNetworkRequest
//import Authentication

//class Auth {
//
//    private let authService = AuthService()
//    private let authentication = AuthController()
//
//    @discardableResult
//    func signUp(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
//        return authService.signUp(email: email, password: password) { [weak self] token, error in
//            self?.complete(token: token, error: error, completion: completion)
//        }
//    }
//
//    @discardableResult
//    func login(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
//        return authService.login(email: email, password: password) { [weak self] token, error in
//            self?.complete(token: token, error: error, completion: completion)
//        }
//    }
//
//    private func complete(token: String?, error: Error?, completion: (_ error: Error?) -> Void) {
//        var error: Error?
//        defer {
//            completion(error)
//        }
//        guard let token = token else {
//            // TODO: error
//            return
//        }
//        authentication.setToken(token)
//    }
//
//    @discardableResult
//    func logout(completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
//        authentication.removeToken()
//        return authService.logout(completion: completion)
//    }
//
//}
