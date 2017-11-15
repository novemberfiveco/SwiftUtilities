//
//  NFUtilities-Nove.swift
//  MyProximus
//
//  Created by Jens Reynders on 19/04/2017.
//  Copyright © 2017 November Five. All rights reserved.
//

import Foundation

extension NFUtilities {
    static func loadStyles(forFileName fileName:String = "styles") {
        if let filePath = Bundle.main.url(forResource: fileName, withExtension: "json"),
            let jsonData = try? Data(contentsOf: filePath) {
            if let stylesArray = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! [[AnyHashable: Any]] {
                for style in stylesArray {
                    DYEStyle.add(fromJSONDictionary: style)
                }
            }
        }
    }
    
    static func loadColors(forFileName fileName:String = "colors") {
        if let filePath = Bundle.main.url(forResource: fileName, withExtension: "json"),
            let jsonData = try? Data(contentsOf: filePath) {
            if let colorsArray = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! [[AnyHashable: Any]] {
                for color in colorsArray {
                    DYEColors.addColor(from: color)
                }
            }
        }
    }
    
    static func heightForAttributedString(_ string:String, withStyleName style:String, inSize:CGSize) -> Double {
        var height = 8.0
        let atString = NSMutableAttributedString(string: string)
        atString.dyeStyleName = style
        height += Double(atString.heightForWidth(inSize.width))
        
        return height
    }
}
