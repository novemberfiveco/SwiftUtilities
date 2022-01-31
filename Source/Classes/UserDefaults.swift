//
//  UserDefaults.swift
//  SwiftUtilities
//
//  Created by Jens Reynders on 31/01/2022.
//  Copyright © 2022 November Five. All rights reserved.
//

import Foundation

@propertyWrapper
public struct UserDefault<T: Codable> {

    public let key: String
    public let defaultValue: T

    public init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T {
        get {
            return UserDefaults.standard.codableObject(dataType: T.self, key: key) ?? defaultValue
        }
        set {
            UserDefaults.standard.setCodableObject(newValue, forKey:key)
        }
    }
}

public extension UserDefaults {

    func codableObject<T : Codable>(dataType: T.Type, key: String) -> T? {

        guard let userDefaultData = data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: userDefaultData)
    }

    func setCodableObject<T: Codable>(_ data: T?, forKey defaultName: String) {

        let encoded = try? JSONEncoder().encode(data)
        set(encoded, forKey: defaultName)
    }
}
