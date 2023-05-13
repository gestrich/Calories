//
//  Food+UI.swift
//  Calorie Log
//
//  Created by Bill Gestrich on 4/29/23.
//  Copyright © 2023 Bill Gestrich. All rights reserved.
//

import Foundation

extension Food {
    
    static let gregorian: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)

    @objc public var presentableDate: String {
        return Food.dateFormatter.string(from: created)
    }
    
    @objc public var sectionedDateName: String {
        if created.includedInTodaysLog() {
            return "Today"
        } else {
            return presentableDate
        }
    }
    
    func isExercise() -> Bool {
        return calories.intValue < 0
    }
    
    func absoluteCalories() -> NSNumber {
        if calories.intValue < 0 {
            return NSNumber(value: abs(calories.intValue))
        } else {
            return calories
        }
    }
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter
    }()
}
