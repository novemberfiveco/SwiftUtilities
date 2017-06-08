//
//  MemoryCache.swift
//  MyProximus
//
//  Created by Jens Reynders on 21/04/2017.
//  Copyright © 2017 November Five. All rights reserved.
//

import Foundation

class MemoryCache<Element> {
    
    enum MemoryCacheValueType {
        case fetched(Element)
        case cached(Element)
        case error
    }
    
    private var keyValueCache: [String: MemoryCacheValueType] = [:]
    
    func cacheValueType(for key: String) -> MemoryCacheValueType? {
        if let value = keyValueCache[key] {
            return value
        }
        
        return nil
    }
    
    func cacheValue(for key: String) -> Element? {
        
        if let valueType = cacheValueType(for: key) {
            switch valueType {
            case let .cached(value):
                return value
            case let .fetched(value):
                return value
            case .error:
                return nil
            }
        } else {
            return nil
        }
    }
    
    func setCache(_ valueType: MemoryCacheValueType, for key: String) {
        keyValueCache[key] = valueType
    }
    
    func clearCache(for key: String? = nil) {
        
        if let key = key {
            keyValueCache.removeValue(forKey: key)
        } else {
            keyValueCache = [:]
        }
    }
}
