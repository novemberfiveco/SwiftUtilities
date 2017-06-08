//
//  APLogger.swift
//
//  Created by Jens Reynders on 30/11/15.
//  Copyright © 2015 Appstrakt. All rights reserved.
//

import Foundation


let GeneralLoggerItemKey = "GENERAL"
func logGeneral(_ flag: APLogFlag, message: String) {
    log(flag, message: message, item: GeneralLoggerItemKey)
}

private extension APLogger {
    class func logError(_ message:String, item:String = APLoggerItemKeyGeneral){
        self.logMessage(message, with: .error, forItem: item)
    }
    
    class func logWarn(_ message:String, item:String = APLoggerItemKeyGeneral){
        self.logMessage(message, with: .warning, forItem: item)
    }
    
    class func logInfo(_ message:String, item:String = APLoggerItemKeyGeneral){
        self.logMessage(message, with: .info, forItem: item)
    }
    
    class func logDebug(_ message:String, item:String = APLoggerItemKeyGeneral){
        self.logMessage(message, with: .debug, forItem: item)
    }
    
    class func logVerbose(_ message:String, item:String = APLoggerItemKeyGeneral){
        self.logMessage(message, with: .verbose, forItem: item)
    }
    
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
func log(_ flag: APLogFlag, message:String, item:String = APLoggerItemKeyGeneral) {
    APLogger.log(flag, message: message, item: item)
}

/// Log a Error message to the APLogger
///
/// - Parameters:
///   - message: Message to log
///   - item: Optional LoggerItemKey
func logError(_ message:String, item:String = APLoggerItemKeyGeneral) {
    APLogger.logError(message, item: item)
}

/// Log a Warning message to the APLogger
///
/// - Parameters:
///   - message: Message to log
///   - item: Optional LoggerItemKey
func logWarn(_ message:String, item:String = APLoggerItemKeyGeneral){
    APLogger.logMessage(message, with: .warning, forItem: item)
}

/// Log an Info message to the APLogger
///
/// - Parameters:
///   - message: Message to log
///   - item: Optional LoggerItemKey
func logInfo(_ message:String, item:String = APLoggerItemKeyGeneral){
    APLogger.logMessage(message, with: .info, forItem: item)
}

/// Log a Debug message to the APLogger
///
/// - Parameters:
///   - message: Message to log
///   - item: Optional LoggerItemKey
func logDebug(_ message:String, item:String = APLoggerItemKeyGeneral){
    APLogger.logMessage(message, with: .debug, forItem: item)
}

/// Log a Verbose message to the APLogger
///
/// - Parameters:
///   - message: Message to log
///   - item: Optional LoggerItemKey
func logVerbose(_ message:String, item:String = APLoggerItemKeyGeneral){
    APLogger.logMessage(message, with: .verbose, forItem: item)
}
