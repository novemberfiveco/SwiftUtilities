//
//  Extensions.swift
//
//  Created by Jens Reynders on 03/12/15.
//  Copyright © 2015 Appstrakt. All rights reserved.
//

import Foundation
import UIKit

public extension String {
    /// Length of a string
    var length: Int {
        return count
    }

    /// Regex check for email conformance.
    func isEmail() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]+$", options: NSRegularExpression.Options.caseInsensitive)
            return regex.firstMatch(in: self, options: [], range: NSMakeRange(0, count)) != nil
        } catch { return false }
    }

    /// Tries to localize the string. When not present in the localized file, the current value is returned.
    func localized() -> String {
        return NFUtilities.localizedString(forKey: self)
    }

    /// Removes all spaces.
    func removingSpaces() -> String {
        return replacingOccurrences(of: " ", with: "")
    }

    var uppercaseFirst: String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst())
        return first + other
    }
}

public extension NSAttributedString {
    func heightForWidth(_ width: CGFloat) -> Float {
        return ceilf(Float(boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height))
    }

    func widthForHeight(_ height: CGFloat) -> Float {
        return ceilf(Float(boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: height), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).width))
    }
}

public extension Double {
    func format(_ f: String) -> String {
        return String(format: "%\(f)f", self)
    }

    func format(for valuta: String) -> String {
        var amountString = ""
        var amount = self

        if self < 0 {
            amount *= -1
            amountString = "-"
        }

        amountString += "\(valuta)\(amount.format(".02"))"

        return amountString
    }

    var inEuro: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""

        var amount = self
        var prefix = ""
        if amount < 0 {
            amount *= -1
            prefix = "-"
        }

        if let formatted = formatter.string(from: NSNumber(value: amount)) {
            return prefix + "€" + formatted
        } else {
            return format(for: "€")
        }
    }

    static var KB: Double {
        return 1024
    }

    static var MB: Double {
        return 1024.0 * .KB
    }

    static var GB: Double {
        return 1024.0 * .MB
    }

    static var TB: Double {
        return 1024.0 * .GB
    }
}

public extension UIView.AnimationCurve {
    func toOptions() -> UIView.AnimationOptions {
        return UIView.AnimationOptions(rawValue: UInt(rawValue << 16))
    }
}

public extension Array {
    /// Request item at index safely
    ///
    /// - Parameter index: Item at index, or nil.
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }

    /// Request item at index safely
    ///
    /// - Parameter index: Item at index, or nil.
    subscript(safe index: UInt) -> Element? {
        return indices ~= Int(index) ? self[Int(index)] : nil
    }

    /// Remove a specific object from the array.
    ///
    /// - Parameter object: Equatable object to be removed.
    mutating func remove<U: Equatable>(_ object: U) {
        var index: Int?
        for (idx, objectToCompare) in enumerated() {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }

        if index != nil {
            remove(at: index!)
        }
    }

    var commaSeparatedString: String {
        guard count > 0 else { return "" }

        let string = reduce("") { str, item in str + "\(item)," }
        return String(string.dropLast())
    }
}

public extension Dictionary {
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }

    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }

    func jsonString() -> String? {
        if let theJSONData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted),
            let jsonString = String(data: theJSONData, encoding: String.Encoding.ascii) {
            return jsonString
        }

        return nil
    }
}

public extension Dictionary where Key == String {
    var queryString: String {
        return reduce("") { (previous, tupple: (key: String, value: Any)) -> String in
            if previous.count == 0 {
                return previous + "\(tupple.key)=\(tupple.value)"
            }
            return previous + "&\(tupple.key)=\(tupple.value)"
        }
    }
}

public extension Dictionary where Value == Any? {
    func omitNilValues() -> [Key: Any] {
        var newDict: [Key: Any] = [:]

        for aKey in keys {
            if let aValue = self[aKey], let value = aValue {
                newDict[aKey] = value
            }
        }
        return newDict
    }
}

public extension URL {
    var queryItems: [URLQueryItem]? {
        let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)
        return urlComponents?.queryItems
    }

    var queryDictionary: [String: String]? {
        return queryItems?.reduce([:]) { (previous, item) -> [String: String] in
            if item.value != nil {
                let aDict = previous
                return aDict.merged(with: [item.name: item.value!])
            } else {
                return previous
            }
        }
    }
}

public extension Bool {
    var stringValue: String {
        return self ? "true" : "false"
    }

    init(stringValue: String) {
        if stringValue == "true" {
            self = true
        } else {
            self = false
        }
    }
}

public extension UIViewController {
    /// Add a child view controller in a given container view
    ///
    /// - Parameters:
    ///   - viewController: The UIViewController to be added as a child.
    ///   - subview: The UIView the viewController should be added in.
    func insertChild(_ viewController: UIViewController?, in subview: UIView?) {
        if let viewController = viewController {
            viewController.willMove(toParent: self)
            addChild(viewController)
            subview?.addSubviewWithConstraints(viewController.view)
            viewController.didMove(toParent: self)
        }
    }
}

public extension UIView {
    /// Returns contraints connecting self and another view, padded by edges or 0.
    ///
    /// - Parameters:
    ///   - subview: UIView to connect to.
    ///   - edges: UIEdgeInsets specifying the padding.
    /// - Returns: Array of NSLayoutConstraints.
    func constraints(to subview: UIView, edges: UIEdgeInsets? = nil) -> [NSLayoutConstraint] {
        return [
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: subview, attribute: .leading, multiplier: 1, constant: edges?.left ?? 0),
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: subview, attribute: .top, multiplier: 1, constant: edges?.top ?? 0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: subview, attribute: .trailing, multiplier: 1, constant: edges?.right ?? 0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: subview, attribute: .bottom, multiplier: 1, constant: edges?.bottom ?? 0),
        ]
    }

    /// Add constraints connecting sef and subview, padded by edges or 0.
    ///
    /// - Parameters:
    ///   - subview: UIView to connect to.
    ///   - edges: UIEdgeInsets specifying the padding.
    func addConstraints(to subview: UIView, edges: UIEdgeInsets? = nil) {
        addConstraints(constraints(to: subview, edges: edges))
    }

    /// Add a subview with constraints, padded by edges or 0.
    ///
    /// - Parameters:
    ///   - view: UIView to add.
    ///   - edges: UIEdgeInsets specifying the padding.
    func addSubviewWithConstraints(_ view: UIView, edges: UIEdgeInsets? = nil) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        addConstraints(to: view, edges: edges)
    }

    /// Convenience function to show/hide a UIView animated.
    ///
    /// - Parameters:
    ///   - show: Boolean specifying to show or hide the view.
    ///   - animated: Boolean soecifying to animated the appearance.
    func show(_ show: Bool = true, animated: Bool = true, duration: Double = 0.25) {
        let alpha: CGFloat = show ? 1.0 : 0.0
        let duration = animated ? duration : 0.0

        if show {
            isHidden = false
            UIView.animate(withDuration: duration, animations: {
                self.alpha = alpha
            })
        } else {
            UIView.animate(withDuration: duration, animations: {
                self.alpha = alpha
            }, completion: { _ in
                self.isHidden = true
            })
        }
    }

    /// Triggers layoutIfNeeded() in an animation block of 0.3 secondes in duration.
    func animate(_ completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        }) { _ in
            completion?()
        }
    }

    /// Load class from Nib
    ///
    /// - Returns: Self
    class func fromNib() -> Self {
        return fromNib(nibName: nil)
    }

    /// Load class from Nib with name
    ///
    /// - Parameter nibName: The name of the nib file
    /// - Returns: Self
    class func fromNib(nibName: String? = nil, bundle: Bundle? = nil) -> Self {
        func fromNibHelper<T>(nibName: String?, bundle: Bundle? = nil) -> T where T: UIView {
            let bundle = bundle ?? Bundle(for: T.self)
            let name = nibName ?? String(describing: T.self)
            return bundle.loadNibNamed(name, owner: nil, options: nil)?.first as? T ?? T()
        }
        return fromNibHelper(nibName: nibName, bundle: bundle)
    }
}

public extension TimeInterval {
    func milliSeconds() -> Double {
        return Double(self * 1000)
    }

    static var second: TimeInterval {
        return 1.0
    }

    static var minute: TimeInterval {
        return .second * 60.0
    }

    static var hour: TimeInterval {
        return .minute * 60.0
    }

    static var day: TimeInterval {
        return .hour * 24
    }

    static var week: TimeInterval {
        return .day * 7.0
    }

    var dateSince1970: Date {
        return Date(timeIntervalSince1970: self)
    }
}
