// swift-tools-version:5.0

/**
 *  DataCache
 *  Copyright (c) November Five 2019
 *  Licensed under the MIT license (see LICENSE file)
 */

 import PackageDescription

 let package = Package(
   name: "SwiftUtilities",
   products: [
     .library(
       name: "SwiftUtilities",
       targets: ["SwiftUtilities"]
     )
   ],
   dependencies: [
   ],
   targets: [
     .target(
       name: "SwiftUtilities",
       path:"Source/Classes"
       )
   ]
 )
