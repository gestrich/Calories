//
//  ThemeKit.swift
//  Calories
//
//  Created by Bill Gestrich on 11/9/15.
//  Copyright © 2015 Bill Gestrich. All rights reserved.
//

import UIKit

class ThemeKit: NSObject {
    
    static func baseColor() -> UIColor {
        return UIColor(red: 118.0/256.0, green: 165.0/256.0, blue: 59.0/256.0, alpha: 1.0)
    }
    
    static func titleColor() -> UIColor {
        return UIColor(red: 162.0/256.0, green: 172.0/256.0, blue: 172.0/256.0, alpha: 1.0)
    }
    
    
    //SwiftUI Additions
    
    static func buttonTextColor() -> UIColor {
        return UIColor(red: 0.4823529412, green: 0.68235294120000001, blue: 0.23921568630000001, alpha: 1.0)
    }
    
    static func plusButtonLength() -> CGFloat {
        return 22.0
    }


}
