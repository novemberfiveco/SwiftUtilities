//
//  File.swift
//
//  Created by Jens Reynders on 03/07/2017.
//  Copyright © 2017 November Five. All rights reserved.
//

import Foundation


public let GeneralLoggerItemKey = "GENERAL"
public func logGeneral(_ flag: APLogFlag, message: String) {
    log(flag, message: message, item: GeneralLoggerItemKey)
}

private extension APLogger {
    class func log(_ flag: APLogFlag, message: String, item:String = APLoggerItemKeyGeneral) {
        
        if item == APLoggerItemKeyGeneral {
            self.logMessage(message, with: flag, forItem: item)
        } else {
            self.logMessage("[" + item + "]" + " " + message, with: flag, forItem: item)
        }
    }
}

/// Log a message to the APLogger for a chosen log level
///
/// - Parameters:
///   - flag: Log level to log the message with
///   - message: Message to log
///   - item: Optional LoggerItemKey
public func log(_ flag: APLogFlag, message:String, item:String = APLoggerItemKeyGeneral) {
    APLogger.log(flag, message: message, item: item)
}

/// Log a Error message to the APLogger
///
/// - Parameters:
///   - message: Message to log
///   - item: Optional LoggerItemKey
public func logError(_ message:String, item:String = APLoggerItemKeyGeneral) {
    APLogger.log(.error, message: message, item: item)
}

/// Log a Warning message to the APLogger
///
/// - Parameters:
///   - message: Message to log
///   - item: Optional LoggerItemKey
public func logWarn(_ message:String, item:String = APLoggerItemKeyGeneral) {
    APLogger.log(.warning, message: message, item: item)
}

/// Log an Info message to the APLogger
///
/// - Parameters:
///   - message: Message to log
///   - item: Optional LoggerItemKey
public func logInfo(_ message:String, item:String = APLoggerItemKeyGeneral) {
    APLogger.log(.info, message: message, item: item)
}

/// Log a Debug message to the APLogger
///
/// - Parameters:
///   - message: Message to log
///   - item: Optional LoggerItemKey
public func logDebug(_ message:String, item:String = APLoggerItemKeyGeneral) {
    APLogger.log(.debug, message: message, item: item)
}

/// Log a Verbose message to the APLogger
///
/// - Parameters:
///   - message: Message to log
///   - item: Optional LoggerItemKey
public func logVerbose(_ message:String, item:String = APLoggerItemKeyGeneral) {
    APLogger.log(.verbose, message: message, item: item)
}
