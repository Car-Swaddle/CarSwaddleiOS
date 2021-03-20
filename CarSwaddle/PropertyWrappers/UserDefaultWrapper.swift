//
//  UserDefaultWrapper.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 3/20/21.
//  Copyright © 2021 CarSwaddle. All rights reserved.
//

import Foundation

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}


@propertyWrapper public struct UserDefault<Value> {
    private let key: String
    private let defaultValue: Value
    private let storage: UserDefaults

    public init(wrappedValue defaultValue: Value,
         key: String,
         storage: UserDefaults = .standard) {
        self.defaultValue = defaultValue
        self.key = key
        self.storage = storage
    }

    public var wrappedValue: Value {
        get {
            let value = storage.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                storage.removeObject(forKey: key)
            } else {
                storage.setValue(newValue, forKey: key)
            }
        }
    }
}

extension UserDefault where Value: ExpressibleByNilLiteral {
    public init(key: String, storage: UserDefaults = .standard) {
        self.init(wrappedValue: nil, key: key, storage: storage)
    }
}
