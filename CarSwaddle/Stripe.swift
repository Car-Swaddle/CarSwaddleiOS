//
//  Stripe.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 12/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Stripe
import CarSwaddleNetworkRequest

public let stripePublishableKey: String = "pk_test_93FPMcPQ4mSaWfjtMWlkGvDr00ytb8KnDJ"
public let appleMerchantIdentifier: String = "merchant.com.carswaddle"


let stripe = StripeClient()

final class StripeClient: NSObject, STPCustomerEphemeralKeyProvider {
    
    private let stripeService = StripeService(serviceRequest: serviceRequest)
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        stripeService.getKeys(apiVersion: apiVersion) { json, error in
            completion(json, error)
        }
    }
    
}
