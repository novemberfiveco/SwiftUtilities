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
    public var length: Int {
        get {
            return self.characters.count
        }
    }
    
    /// Regex check for email conformance.
    public func isEmail() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]+$", options: NSRegularExpression.Options.caseInsensitive)
            return regex.firstMatch(in: self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
        } catch { return false }
    }
    
    /// Tries to localize the string. When not present in the localized file, the current value is returned.
    public func localized() -> String {
        return NFUtilities.localizedString(forKey: self)
    }
    
    /// Removes all spaces.
    public func removingSpaces() -> String{
        return self.replacingOccurrences(of: " ", with: "")
    }

    public var uppercaseFirst: String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
}

public extension NSAttributedString {
    public func heightForWidth(_ width: CGFloat) -> Float {
        return ceilf(Float(self.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height))
    }

    public func widthForHeight(_ height: CGFloat) -> Float {
        return ceilf(Float(self.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: height), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).width))
    }
}

public extension Double {
    public func format(_ f: String) -> String {
        return String(format: "%\(f)f", self)
    }
    
    public func format(for valuta: String) -> String {
        var amountString = ""
        var amount = self
        
        if self < 0 {
            amount *= -1
            amountString = "-"
        }
        
        amountString += "€\(amount.format(".02"))"
        
        return amountString
    }
    
    public var inEuro: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        
        var amount = self
        var prefix = ""
        if amount < 0{
            amount *= -1
            prefix = "-"
        }
        
        if let formatted = formatter.string(from: NSNumber(value: amount)) {
            return prefix + "€" + formatted
        } else {
            return format(for: "€")
        }
        
    }
    
    
    public static var KB: Double {
        return 1024
    }
    public static var MB: Double {
        return 1024.0 * .KB
    }
    public static var GB: Double {
        return 1024.0 * .MB
    }
    public static var TB: Double {
        return 1024.0 * .GB
    }
}

public extension UIViewAnimationCurve {
    public func toOptions() -> UIViewAnimationOptions {
        return UIViewAnimationOptions(rawValue: UInt(rawValue << 16))
    }
}


public extension Array {
    
    /// Request item at index safely
    ///
    /// - Parameter index: Item at index, or nil.
    public subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
    
    /// Request item at index safely
    ///
    /// - Parameter index: Item at index, or nil.
    public subscript (safe index: UInt) -> Element? {
        return indices ~= Int(index) ? self[Int(index)] : nil
    }
    
    
    /// Remove a specific object from the array.
    ///
    /// - Parameter object: Equatable object to be removed.
    public mutating func remove<U: Equatable>(_ object: U) {
        var index: Int?
        for (idx, objectToCompare) in self.enumerated() {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        
        if(index != nil) {
            self.remove(at: index!)
        }
    }
    
    public var commaSeparatedString: String {
        
        guard self.count > 0 else { return "" }
        
        let string = self.reduce("", { (str, item) in return str + "\(item)," })
        return string.substring(to: string.index(string.endIndex, offsetBy: -1))
    }
}

public extension Dictionary {
    
    public mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    public func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
}

public extension Dictionary where Key == String {
    public var queryString: String {
        return self.reduce("") { (previous, tupple: (key: String, value: Any)) -> String in
            if previous.characters.count == 0 {
                return previous + "\(tupple.key)=\(tupple.value)"
            }
            return previous + "&\(tupple.key)=\(tupple.value)"
        }
    }
}

public extension Dictionary where Value == Any? {
    public func omitNilValues() -> [Key: Any] {
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
    public var queryItems: [URLQueryItem]? {
        let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)
        return urlComponents?.queryItems
    }
    
    public var queryDictionary: [String: String]? {
        return queryItems?.reduce([:], { (previous, item) -> [String: String] in
            if item.value != nil {
                let aDict = previous
                return aDict.merged(with: [item.name: item.value!])
            } else {
                return previous
            }
        })
    }
}

public extension Bool {
    public var stringValue: String {
        return self ? "true" : "false"
    }
    
    public init(stringValue: String) {
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
    public func insertChild(_ viewController:UIViewController?, in subview:UIView?) {
        if let viewController = viewController {
            viewController.willMove(toParentViewController: self)
            self.addChildViewController(viewController)
            subview?.addSubviewWithConstraints(viewController.view)
            viewController.didMove(toParentViewController: self)
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
    public func constraints(to subview:UIView, edges: UIEdgeInsets? = nil) -> [NSLayoutConstraint] {
        return [
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: subview, attribute: .leading, multiplier: 1, constant: edges?.left ?? 0),
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: subview, attribute: .top, multiplier: 1, constant: edges?.top ?? 0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: subview, attribute: .trailing, multiplier: 1, constant: edges?.right ?? 0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: subview, attribute: .bottom, multiplier: 1, constant: edges?.bottom ?? 0)
        ]
    }
    
    
    /// Add constraints connecting sef and subview, padded by edges or 0.
    ///
    /// - Parameters:
    ///   - subview: UIView to connect to.
    ///   - edges: UIEdgeInsets specifying the padding.
    public func addConstraints(to subview:UIView, edges: UIEdgeInsets? = nil) {
        self.addConstraints(self.constraints(to: subview, edges: edges))
    }
    
    
    /// Add a subview with constraints, padded by edges or 0.
    ///
    /// - Parameters:
    ///   - view: UIView to add.
    ///   - edges: UIEdgeInsets specifying the padding.
    public func addSubviewWithConstraints(_ view:UIView, edges: UIEdgeInsets? = nil) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        self.addConstraints(to: view, edges: edges)
    }
    
    
    /// Convenience function to show/hide a UIView animated.
    ///
    /// - Parameters:
    ///   - show: Boolean specifying to show or hide the view.
    ///   - animated: Boolean soecifying to animated the appearance.
    public func show(_ show: Bool = true, animated: Bool = true, duration: Double = 0.25) {
        let alpha:CGFloat = show ? 1.0 : 0.0
        let duration = animated ? duration : 0.0
        
        if show {
            isHidden = false
            UIView.animate(withDuration: duration, animations: {
                self.alpha = alpha
            })
        } else {
            UIView.animate(withDuration: duration, animations: {
                self.alpha = alpha
            }, completion: { (finished) in
                self.isHidden = true
            })
        }
    }
    
    
    /// Triggers layoutIfNeeded() in an animation block of 0.3 secondes in duration.
    public func animate(_ completion: (() -> ())? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        }) { (_) in
            completion?()
        }
    }
    
    
    /// Load class from Nib
    ///
    /// - Returns: Self
    public class func fromNib() -> Self {
        return fromNib(nibName: nil)
    }
    
    
    /// Load class from Nib with name
    ///
    /// - Parameter nibName: The name of the nib file
    /// - Returns: Self
    public class func fromNib(nibName: String?) -> Self {
        func fromNibHelper<T>(nibName: String?) -> T where T : UIView {
            let bundle = Bundle(for: T.self)
            let name = nibName ?? String(describing: T.self)
            return bundle.loadNibNamed(name, owner: nil, options: nil)?.first as? T ?? T()
        }
        return fromNibHelper(nibName: nibName)
    }
}


public extension TimeInterval {
    public func milliSeconds() -> Double {
        return Double(self * 1000)
    }
    
    public static var second: TimeInterval {
        return 1.0
    }
    
    public static var minute: TimeInterval {
        return .second * 60.0
    }
    
    public static var hour: TimeInterval {
        return .minute * 60.0
    }
    
    public static var day: TimeInterval {
        return .hour * 24
    }
    
    public static var week: TimeInterval {
        return .day * 7.0
    }
    
    public var dateSince1970: Date {
        return Date(timeIntervalSince1970: self)
    }
}
