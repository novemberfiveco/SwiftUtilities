//
//  DataCache+ApiEndpoint.swift
//  MyProximus
//
//  Created by Jens Reynders on 10/04/2017.
//  Copyright © 2017 November Five. All rights reserved.
//

import Foundation

extension DataCache {
    func add(_ data: Data?, for endpoint: ApiEndPoint) -> CacheValueType {
        return add(data, for: endpoint.cacheKey ?? endpoint.path)
    }
    
    func cacheValue(for endpoint: ApiEndPoint, expiryDate: Date? = nil) -> CacheValueType {
        return cacheValue(for: endpoint.cacheKey ?? endpoint.path, expiryDate: expiryDate)
    }
    
    func date(for endpoint: ApiEndPoint) -> Date {
        return date(for: endpoint.cacheKey ?? endpoint.path) ?? Date(timeIntervalSince1970: 0)
    }
}

extension APConnectionManager {
    
    /// Do a normal request, but cache the response when the connection's status code was lower then 400
    ///
    /// - Parameters:
    ///   - target: a Proximus ApiEndPoint
    ///   - completionClosure: completion closure
    ///   - nextPageClosure: next page closure
    static func cacheRequest(_ target: ApiEndPoint, completionClosure: @escaping RequestResultClosure, nextPageClosure: NextRequestClosure? = nil) {
        self.request(target, completionClosure: { (result) in
            switch result {
            case let .success(connectionObject):
                if connectionObject.responseStatusCode < 300 {
                    switch DataCache.synchronizedCache.add(connectionObject.downloadedData, for: target) {
                    case .error:
                        logWarn("Failed caching response")
                    default:
                        break
                    }
                }
                completionClosure(result)
            default:
                completionClosure(result)
            }
        }, nextPageClosure: nextPageClosure)
    }
    
    /// Do a normal request, but cache the response when the connection's status code was lower then 400
    ///
    /// - Parameters:
    ///   - target: a Proximus ApiEndPoint
    ///   - completionClosure: completion closure
    static func cacheRequest(_ target: ApiEndPoint, completionClosure: @escaping RequestResultClosure) {
        self.cacheRequest(target, completionClosure: completionClosure, nextPageClosure: nil)
    }
}


extension ApiEndPoint {
    var intervalSinceLastSync: TimeInterval {
        return Date().timeIntervalSince1970 - DataCache.synchronizedCache.date(for: self).timeIntervalSince1970
    }
    
    func shouldSync() -> Bool {
        return self.intervalSinceLastSync > self.requestIntervalCap
    }
    
    var requestIntervalCap: TimeInterval {
        #if Debug || Beta
            return .second * 10
        #endif
        switch self {
        case .billingStructure:
            return .minute * 5
        case .billingBalance:
            return .minute * 2
            
        case .loyaltyEligibility:
            return .minute * 5
        case .loyaltySubscription:
            return .minute * 5
            
        case .productsOverview:
            return .second * 5
        default:
            return .second * 10
        }
    }
    
    var cacheKey: String? {
        switch self {
        case let .billingAccountOverview(customerId):
            return customerId + "/" + path
        case let .productsOverview(customerId):
            return customerId + "/" + path
        default:
            return nil
        }
    }
}
