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
            let value = UserDefaults.standard.value(forKey: "test") as! NSNumber?
            if let toRet =  value {
                return toRet
            } else {
                return NSNumber(value: 2000.0 as Float)
            }
        }
        
        set(newMaxColorieCount){
            
            UserDefaults.standard.setValue(newMaxColorieCount, forKey: "test")
            UserDefaults.standard.synchronize()
        }
    }
    
    var freshStart : Date {
        
        get {
            let value = UserDefaults.standard.value(forKey: "freshStart")as! Date?
            if let toRet =  value {
                return toRet
            } else {
                let date = Date()
                UserDefaults.standard.setValue(date, forKey: "freshStart")
                UserDefaults.standard.synchronize()
                return date
            }
        }
        
        set(newFreshStart){
            
            UserDefaults.standard.setValue(newFreshStart, forKey: "freshStart")
            UserDefaults.standard.synchronize()
        }
    }
}
