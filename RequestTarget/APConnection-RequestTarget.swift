//
//  APConnection-RequestTarget.swift
//  MyProximus
//
//  Created by Jens Reynders on 01/03/2017.
//  Copyright © 2017 November Five. All rights reserved.
//

import Foundation

/// Available HTTP methods
enum HttpMethod {
    case get
    case post
    case put
    case delete
}


/// RequestTarget protocol, used to configure an api request. Representing an endpoint on the server.
protocol RequestTarget {
    var baseUrl: URL { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var method: HttpMethod { get }
    var parameters: [String: Any]? { get }
    var queueName: String? { get }
}

/// Request error
enum RequestError : Error {
    case failedSetup
    case noInternet
    case timedOut
}

/// Request result
enum RequestResult {
    case success(APConnectionObject)
    case failure(Error?, APConnectionObject?)
}


extension APConnectionObject {
    
    
    /// Returns an optional APConnectionObject for the given RequestTarget object
    ///
    /// - Parameter target: Object conforming to RequestTarget
    /// - Returns: optional APConnectionObject
    static func connection(for target: RequestTarget) -> APConnectionObject? {
        var connection: APConnectionObject?
        
        switch target.method {
        case .get:
            connection = APConnectionObject.getWith(target.baseUrl.appendingPathComponent(target.path), parameters: target.parameters, headers: target.headers)
            
        case .post:
            var body: Data?
            if let parameters = target.parameters,
                let postParameterString = APConnectionObject.queryString(forParameters: parameters, allowedCharacters: nil) {
                body = postParameterString.data(using: .utf8)
            }
            connection = APConnectionObject.post(with: target.baseUrl.appendingPathComponent(target.path), data: body, headers: target.headers)
            
        case .put:
            var body: Data?
            if let parameters = target.parameters,
                let postParameterString = APConnectionObject.queryString(forParameters: parameters, allowedCharacters: nil) {
                body = postParameterString.data(using: .utf8)
            }
            connection = APConnectionObject.put(with: target.baseUrl.appendingPathComponent(target.path), data: body, headers: target.headers)
            
        case .delete:
            connection = APConnectionObject.delete(with: target.baseUrl.appendingPathComponent(target.path), headers: target.headers)
        }
        
        return connection
    }
}


/// Closure containing a RequestResult
typealias RequestResultClosure = (_ result: RequestResult) -> ()


/// 
typealias NextRequestClosure = (_ result: RequestResult) -> (APConnectionObject?)

extension APConnectionManager { 
    
    /// Start a request for a given RequestTarget
    ///
    /// - Parameters:
    ///   - target: Object conforming to RequestTarget
    ///   - completionClosure: Result closure, invoked after a failed setup or when the api responded.
    static func request(_ target: RequestTarget, completionClosure: @escaping RequestResultClosure, nextPageClosure: NextRequestClosure? = nil) {
        
        guard let connection = APConnectionObject.connection(for: target) else {
            completionClosure(.failure(RequestError.failedSetup, nil))
            return
        }
        
        let success = self.sharedInstance().addConnection(connection, toQueue: target.queueName, handlerBlock: { (connectionObject, success, error) in
            
            if success {
                completionClosure(.success(connectionObject))
            } else {
                completionClosure(.failure(error, connectionObject))
            }
            
            self.sharedInstance().finalizeHandlingConnection(connectionObject, withError: error, additionalInfo: nil)
            
        }, nextPage: { (connectionObject, success, error) -> APConnectionObject? in
            if success {
                return nextPageClosure?(.success(connectionObject))
            } else {
                return nextPageClosure?(.failure(error, connectionObject))
            }
        })
        
        if !success {
            completionClosure(.failure(RequestError.noInternet, connection))
        }
    }
}

