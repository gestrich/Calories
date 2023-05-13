//
//  Food.swift
//  Calories
//
//  Created by Bill Gestrich on 1/15/15.
//  Copyright (c) 2015 Bill Gestrich. All rights reserved.
//

import Foundation
import CoreData

public class Food: NSManagedObject, Identifiable {
    @NSManaged public var calories: NSNumber
    @NSManaged public var created: Date
    @NSManaged public var name: String
}
