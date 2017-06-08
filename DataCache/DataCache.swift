//
//  ResponseCache.swift
//  MyProximus
//
//  Created by Jens Reynders on 10/04/2017.
//  Copyright © 2017 November Five. All rights reserved.
//

import Foundation
import Valet

enum CacheValueType {
    case new
    case replaced(oldData: Data, date: Date)
    case deleted
    case error
    case cache(data: Data, date: Date)
    case expired(data: Data, date: Date)
}

class DataCache {
    
    
    /// Keychain DataCache which is synchronized on the user's iCloud account, available on all devices linked to that account
    static let synchronizedCache = DataCache(cacheIdentifier: "myproximus.synchronizedCache.keychainIdentifier", synchronizable: true)
    
    /// Keychain DataCache accessable localy
    static let mainCache = DataCache(cacheIdentifier: "myproximus.mainCache.keychainIdentifier", synchronizable: false)
    
    /// DataCache initilizer. Initialize a separate/private instance of a keychain DataCache
    ///
    /// - Parameters:
    ///   - cacheIdentifier: Identifier used within the keychain
    ///   - synchronizable: Make it synchronizable within iCloud
    init(cacheIdentifier: String, synchronizable: Bool = false) {
        if synchronizable {
            synchronizableValet = VALSynchronizableValet(identifier: "myproximus.\(cacheIdentifier)", accessibility: .whenUnlocked)
        } else {
            valet = VALValet(identifier: "myproximus.\(cacheIdentifier)", accessibility: .whenUnlocked)
        }
    }
    
    func add(_ data: Data?, for key: String) -> CacheValueType {
        guard let valet = (synchronizableValet ?? valet) else { return .error }
        
        guard let data = data, data.count > 0 else { return .error }
        
        let oldData = valet.object(forKey: key)
        let oldDate = valet.date(for: key)
        
        if valet.setObject(data, forKey: key) && valet.set(Date(), for: key) {
            if let oldData = oldData, let oldDate = oldDate {
                return .replaced(oldData: oldData, date: oldDate)
            } else {
                return .new
            }
        }
        
        return .error
    }
    
    func cacheValue(for key: String, expiryDate: Date? = nil) -> CacheValueType {
        guard let valet = (synchronizableValet ?? valet) else { return .error }
        
        guard let data = valet.object(forKey: key),
            let date = valet.date(for: key) else {
                return .error
        }
        
        if let expiryDate = expiryDate, (date as NSDate).isEarlierThanDate(expiryDate) {
            return .expired(data: data, date: date)
        }
        
        return .cache(data: data, date: date)
    }
    
    func date(for key: String) -> Date? {
        return (synchronizableValet ?? valet)?.date(for: key)
    }
    
    func clear(for key: String) -> CacheValueType {
        guard let valet = (synchronizableValet ?? valet) else { return .error }
        
        let success = valet.removeObject(forKey: key)
        _ = valet.removeObject(forKey: key.dateKey)
        
        return success ? .deleted : .error
    }
    
    func clear() {
        (synchronizableValet ?? valet)?.removeAllObjects()
    }
    
    // MARk: - Private
    private var synchronizableValet: VALSynchronizableValet?
    private var valet: VALValet?
}


// MARK: - Private extensions
private extension String {
    var dateKey: String {
        return "date." + self
    }
}

private extension VALValet {
    func set(_ date: Date, for key: String) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: date)
        return self.setObject(data, forKey: key.dateKey)
    }
    
    func date(for key: String) -> Date? {
        if let data = self.object(forKey: key.dateKey),
            let date: Date = NSKeyedUnarchiver.unarchiveObject(with: data) as? Date {
            return date
        } else {
            return nil
        }
    }
}
