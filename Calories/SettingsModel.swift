//
//  SettingsModel.swift
//  Calories
//
//  Created by Bill Gestrich on 12/27/14.
//  Copyright (c) 2014 Bill Gestrich. All rights reserved.
//

import UIKit

class SettingsModel: NSObject {
    
    var maxCalorieCount : NSNumber {
        
        get {
            //NSUserDefaults.standardUserDefaults().removeObjectForKey("test")
            let value = NSUserDefaults.standardUserDefaults().valueForKey("test") as! NSNumber?
            if let toRet =  value {
                return toRet
            } else {
                return NSNumber(float: 2000.0)
            }
        }
        
        set(newMaxColorieCount){
            
            NSUserDefaults.standardUserDefaults().setValue(newMaxColorieCount, forKey: "test")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var freshStart : NSDate {
        
        get {
            let value = NSUserDefaults.standardUserDefaults().valueForKey("freshStart")as! NSDate?
            if let toRet =  value {
                return toRet
            } else {
                let date = NSDate()
                NSUserDefaults.standardUserDefaults().setValue(date, forKey: "freshStart")
                NSUserDefaults.standardUserDefaults().synchronize()
                return date
            }
        }
        
        set(newFreshStart){
            
            NSUserDefaults.standardUserDefaults().setValue(newFreshStart, forKey: "freshStart")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}
