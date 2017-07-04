//
//  SwiftBeaverLoggerService.swift
//  MyProximus
//
//  Created by Jens Reynders on 17/05/2017.
//  Copyright © 2017 November Five. All rights reserved.
//

import UIKit
import SwiftyBeaver

class SwiftBeaverLoggerService: NSObject, APLoggerService {
    var logLevel: APLogLevel = []
    var extendedInfo: Bool = false
    
    let beaverLog = SwiftyBeaver.self
    
    init(appID: String, appSecret: String, encryptionKey: String) {
        super.init()
        
        // SwiftyBeaver
        let cloud = SBPlatformDestination(appID: appID, appSecret: appSecret, encryptionKey: encryptionKey)
        //        cloud.analyticsUserName = UIDevice.current.name
        beaverLog.addDestination(cloud)
        
        let fileDestination = FileDestination()
        beaverLog.addDestination(fileDestination)
        
    }
    
    func logMessage(_ message: String!, with flag: APLogFlag, function: UnsafePointer<Int8>!, line: UInt) {
        if flag.contains(.error) {
            beaverLog.error(message)
        } else if flag.contains(.warning) {
            beaverLog.warning(message)
        } else if flag.contains(.info) {
            beaverLog.info(message)
        } else if flag.contains(.debug) {
            beaverLog.debug(message)
        } else if flag.contains(.verbose) {
            beaverLog.verbose(message)
        }
    }
}
