//
//  Date+Utils.swift
//  Calorie Log
//
//  Created by Bill Gestrich on 11/17/19.
//  Copyright © 2019 Bill Gestrich. All rights reserved.
//

import Foundation

extension Date {
    
    static func startOfTodaysLog() -> Date {
        let today = Date()
        
        let components = Set<Calendar.Component>([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day, Calendar.Component.hour])
        var todayComponents = gregorian.dateComponents(components, from: today)
        
        let localStartHour = 3 //3am
        if (gregorian.timeZone.isDaylightSavingTime(for: today) != false) {
            todayComponents.hour = localStartHour
        } else {
            todayComponents.hour = localStartHour + 1 //4am local during non-dst
        }
        
        var startDate = gregorian.date(from: todayComponents)!
        if startDate.timeIntervalSince1970 > today.timeIntervalSince1970 {
            //Start time in future (it is between 12a - 3a now), use yesterday's start hour
            startDate = startDate.addingTimeInterval(-60*60*24)
        }
        return startDate
    }
    
    static let gregorian: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    
    func includedInTodaysLog() -> Bool {
        let startDate = Date.startOfTodaysLog()
        let endDate = startDate.addingTimeInterval(60*60*24)
        if startDate.compare(self) != .orderedDescending && endDate.compare(self) == .orderedDescending {
            return true
        } else {
            return false
        }
    }

}
