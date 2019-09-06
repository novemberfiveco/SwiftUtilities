//
//  NFUtilities.swift
//
//  Created by Jens Reynders on 17/05/16.
//  Copyright © 2016 November Five. All rights reserved.
//

import Foundation

public class NFUtilities {
    class func localizedString(forKey key: String) -> String {
        let aString = NSLocalizedString(key, comment: "")
        if !aString.isEmpty {
            return aString
        } else {
            #if Debug
                return key
            #else
                return ""
            #endif
        }
    }

    public static func commaSeparatedStringForIds(_ ids: [Int]) -> String {
        let string = ids.reduce("") { str, id in str + "\(id)," }
        return string
    }

    public static var distanceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.locale = Locale.current
        return formatter
    }()
}

/// Filter out only the unique values
///
/// - Parameter source: Array of equatable objects
/// - Returns: Array of only the unique values
public func distinct<T: Equatable>(_ source: [T]?) -> [T] {
    var unique = [T]()
    for item in source ?? [] {
        if !unique.contains(item) {
            unique.append(item)
        }
    }
    return unique
}

/// Clip a given value between a minimum and maximum value
///
/// - Parameters:
///   - minValue: Comparable minimum value
///   - value: Comparable value to compare
///   - maxValue: Comparable maximum value
/// - Returns: Clipped value or value
public func clip<T: Comparable>(min minValue: T, value: T, max maxValue: T) -> T {
    return min(maxValue, max(value, minValue))
}

/// Dispatch to Queue with delay
///
/// - Parameters:
///   - milliseconds: number of milliseconds it will get delayed. Default = 200
///   - queue: DispatchQueue on which to dispatch. Default = .main
///   - closure: Code block to execute
public func delay(_ milliseconds: Int = 200, on queue: DispatchQueue = .main, _ closure: @escaping () -> Void) {
    queue.asyncAfter(deadline: .now() + .milliseconds(milliseconds)) {
        closure()
    }
}

/// Dispatch to Queue
///
/// - Parameters:
///   - dispatchQueue: DispatchQueue on which to dispatch. Default = .main
///   - closure: Code block to execute
public func queue(_ dispatchQueue: DispatchQueue = .main, _ closure: @escaping () -> Void) {
    dispatchQueue.async {
        closure()
    }
}

/// Dispatch to main Queue
///
/// - Parameter closure: Code block to execute
public func main(_ closure: @escaping () -> Void) {
    queue(.main, closure)
}
