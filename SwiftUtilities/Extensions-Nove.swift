//
//  Extensions-Nove.swift
//  MyProximus
//
//  Created by Jens Reynders on 19/04/2017.
//  Copyright © 2017 November Five. All rights reserved.
//

import Foundation

extension APManagedObjectController {
    func indexPath(for object:NSManagedObject) -> IndexPath? {
        var section:Int?
        var row:Int?
        
        if let objectsInSections = self.fetchedObjectsInSections {
            for (aSection, anArray) in objectsInSections.enumerated() {
                for (aRow, anObject) in anArray.enumerated() {
                    if anObject == object {
                        section = aSection
                        row = aRow
                    }
                }
            }
        }
        
        if let section = section, let row = row {
            return IndexPath(row: row, section: section)
        }
        
        return nil
    }
}

extension Date {
    func isEarlierThanAWeek() -> Bool {
        return (self as NSDate).isEarlierThanDate(((Date() as NSDate).atStartOfDay() as NSDate).subtractingDays(7))
    }
    
    static func weekFromNow() -> Date {
        return ((Date() as NSDate).atStartOfDay() as NSDate).subtractingDays(7)
    }
    
    func isEarlierThanAWeek(_ fromDate:Date) -> Bool {
        return (self as NSDate).isEarlierThanDate(((fromDate as NSDate).atStartOfDay() as NSDate).subtractingDays(7))
    }
}
