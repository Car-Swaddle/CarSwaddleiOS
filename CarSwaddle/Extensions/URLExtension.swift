//
//  URLExtension.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/20/21.
//  Copyright © 2021 CarSwaddle. All rights reserved.
//

import Foundation

extension URL {
    public var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
    }
}
