//
//  Food.swift
//  Calories
//
//  Created by Bill Gestrich on 1/15/15.
//  Copyright (c) 2015 Bill Gestrich. All rights reserved.
//

import Foundation
import CoreData

class Food: NSManagedObject {

    @NSManaged var calories: NSNumber
    @NSManaged var created: NSDate
    @NSManaged var name: String

}
