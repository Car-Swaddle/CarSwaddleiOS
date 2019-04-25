//
//  ServiceRequest.swift
//  
//
//  Created by Kyle Kendall on 11/3/18.
//

import NetworkRequest
import CarSwaddleNetworkRequest
import CarSwaddleUI

#if targetEnvironment(simulator)
private let localDomain = "127.0.0.1"
#else
private let localDomain = "Kyles-MacBook-Pro.local"
#endif

private let productionDomain = "www.carswaddle.com"
private let productionHerokuDomain = "www.car-swaddle.herokuapp.com"
private let stagingDomain = "safe-ridge-47447.herokuapp.com"

private let domainUserDefaultsKey = "domain"

extension Tweak {
    
    private static let domainOptions = Tweak.Options.string(values: [localDomain, productionDomain, stagingDomain, productionHerokuDomain])
    static let domain: Tweak = {
        let valueDidChange: (_ tweak: Tweak) -> Void = { tweak in
            _serviceRequest = nil
        }
        let domain = Tweak(label: "Domain", options: Tweak.domainOptions, userDefaultsKey: domainUserDefaultsKey, valueDidChange: valueDidChange, defaultValue: productionDomain, requiresAppReset: true)
        return domain
    }()
    
}

fileprivate var _serviceRequest: Request?
public var serviceRequest: Request {
    if let _serviceRequest = _serviceRequest {
        return _serviceRequest
    }
    let newServiceRequest = createServiceRequest()
    _serviceRequest = newServiceRequest
    return newServiceRequest
}

public func createServiceRequest() -> Request {
    let domain = (Tweak.domain.value as? String) ?? productionDomain
    if domain == localDomain {
        let request = Request(domain: domain)
        request.port = 3000
        request.timeout = 15
        request.defaultScheme = .http
        return request
    } else {
        let request = Request(domain: domain)
        request.timeout = 15
        request.defaultScheme = .https
        return request
    }
}

public func finishTasksAndInvalidate(completion: @escaping () -> Void) {
    serviceRequest.urlSession.getTasksWithCompletionHandler { dataTask, uploadTask, downloadTask in
        for task in dataTask {
            task.cancel()
        }
        for task in uploadTask {
            task.cancel()
        }
        for task in downloadTask {
            task.cancel()
        }
        completion()
    }
}
