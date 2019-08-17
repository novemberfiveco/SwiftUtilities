//
//  Storyboard+convenience.swift
//
//  Created by Jens Reynders on 19/10/2017.
//  Copyright © 2017 November Five. All rights reserved.
//

import Foundation
import UIKit

public protocol StoryboardInstantiable {
    static var storyboardName: String { get }
    static var storyboardBundle: Bundle? { get }
    static var storyboardIdentifier: String? { get }
}

public extension StoryboardInstantiable {
    static var storyboardIdentifier: String? { return String(describing: Self.self) }
    static var storyboardBundle: Bundle? { return nil }

    static func instantiate() -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: storyboardBundle)

        if let storyboardIdentifier = storyboardIdentifier {
            return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
        } else {
            return storyboard.instantiateInitialViewController() as! Self
        }
    }
}
