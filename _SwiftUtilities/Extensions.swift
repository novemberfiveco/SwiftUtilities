//
//  Extensions.swift
//
//  Created by Jens Reynders on 03/12/15.
//  Copyright © 2015 Appstrakt. All rights reserved.
//

import Foundation

extension String {
    /// Length of a string
    public var length: Int {
        get {
            return self.characters.count
        }
    }
    
    /// Regex check for email conformance.
    func isEmail() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]+$", options: NSRegularExpression.Options.caseInsensitive)
            return regex.firstMatch(in: self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
        } catch { return false }
    }
    
    /// Tries to localize the string. When not present in the localized file, the current value is returned.
    func localized() -> String {
        return NFUtilities.localizedString(forKey: self)
    }
    
    /// Removes all spaces.
    func removingSpaces() -> String{
        return self.replacingOccurrences(of: " ", with: "")
    }
}

extension NSAttributedString {
    func heightForWidth(_ width: CGFloat) -> Float {
        return ceilf(Float(self.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height))
    }
}

extension Double {
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
        
        amountString += "€\(amount.format(".02"))"
        
        return amountString
    }
}

extension UIViewAnimationCurve {
    func toOptions() -> UIViewAnimationOptions {
        return UIViewAnimationOptions(rawValue: UInt(rawValue << 16))
    }
}

typealias IndexPathTuple = (section:Int, row:Int)
extension IndexPath {
    func tuple() -> IndexPathTuple {
        return (self.section, self.row)
    }
}

extension Array {
    
    /// Request item at index safely
    ///
    /// - Parameter index: Item at index, or nil.
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
    
    /// Request item at index safely
    ///
    /// - Parameter index: Item at index, or nil.
    subscript (safe index: UInt) -> Element? {
        return indices ~= Int(index) ? self[Int(index)] : nil
    }
    
    
    /// Remove a specific object from the array.
    ///
    /// - Parameter object: Equatable object to be removed.
    mutating func remove<U: Equatable>(_ object: U) {
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
    
    var commaSeparatedString: String {
        
        guard self.count > 0 else { return "" }
        
        let string = self.reduce("", { (str, item) in return str + "\(item)," })
        return string.substring(to: string.index(string.endIndex, offsetBy: -1))
    }
}

extension Dictionary {
    
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
}

extension Dictionary where Key == String, Value == Value {
    var queryString: String {
        return self.reduce("") { (previous, tupple: (key: String, value: Any)) -> String in
            if previous.characters.count == 0 {
                return previous + "\(tupple.key)=\(tupple.value)"
            }
            return previous + "&\(tupple.key)=\(tupple.value)"
        }
    }
}

extension URL {
    var queryItems: [URLQueryItem]? {
        let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)
        return urlComponents?.queryItems
    }
    
    var queryDictionary: [String: String]? {
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

extension Bool {
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

extension UIViewController {
    
    /// Add a child view controller in a given container view
    ///
    /// - Parameters:
    ///   - viewController: The UIViewController to be added as a child.
    ///   - subview: The UIView the viewController should be added in.
    func insertChild(_ viewController:UIViewController?, in subview:UIView?) {
        if let viewController = viewController {
            viewController.willMove(toParentViewController: self)
            self.addChildViewController(viewController)
            subview?.addSubviewWithConstraints(viewController.view)
            viewController.didMove(toParentViewController: self)
        }
    }
}

extension UIView {
    
    
    /// Returns contraints connecting self and another view, padded by edges or 0.
    ///
    /// - Parameters:
    ///   - subview: UIView to connect to.
    ///   - edges: UIEdgeInsets specifying the padding.
    /// - Returns: Array of NSLayoutConstraints.
    func constraints(to subview:UIView, edges: UIEdgeInsets? = nil) -> [NSLayoutConstraint] {
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
    func addConstraints(to subview:UIView, edges: UIEdgeInsets? = nil) {
        self.addConstraints(self.constraints(to: subview, edges: edges))
    }
    
    
    /// Add a subview with constraints, padded by edges or 0.
    ///
    /// - Parameters:
    ///   - view: UIView to add.
    ///   - edges: UIEdgeInsets specifying the padding.
    func addSubviewWithConstraints(_ view:UIView, edges: UIEdgeInsets? = nil) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        self.addConstraints(to: view, edges: edges)
    }
    
    
    /// Convenience function to show/hide a UIView animated.
    ///
    /// - Parameters:
    ///   - show: Boolean specifying to show or hide the view.
    ///   - animated: Boolean soecifying to animated the appearance.
    func show(_ show:Bool = true, animated:Bool = true) {
        let alpha:CGFloat = show ? 1.0 : 0.0
        let duration = animated ? 0.35 : 0.0
        
        if show {
            isHidden = false
            UIView.animate(withDuration: duration, animations: {
                self.alpha = alpha
            })
        }else{
            UIView.animate(withDuration: duration, animations: {
                self.alpha = alpha
            }, completion: { (finished) in
                self.isHidden = true
            })
        }
    }
    
    
    /// Triggers layoutIfNeeded() in an animation block of 0.3 secondes in duration.
    func animate() {
        UIView.animate(withDuration: 0.3) { 
            self.layoutIfNeeded()
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


typealias BusinessTupple = (start:TimeInterval, end:TimeInterval)
extension TimeInterval {
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
    
    static var businessDay:BusinessTupple {
        return (start: (60.0 * 60.0 * 8), end: (60.0 * 60.0 * 20))
    }
    
    var dateSince1970: Date? {
        return Date(timeIntervalSince1970: self)
    }
}
