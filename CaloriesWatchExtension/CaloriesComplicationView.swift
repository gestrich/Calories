//
//  CaloriesComplicationView.swift
//  CaloriesWatchExtension
//
//  Created by Bill Gestrich on 5/3/23.
//  Copyright © 2023 Bill Gestrich. All rights reserved.
//

import SwiftUI
import CoreData

struct CaloriesComplicationView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: PersistenceManager.foodFetchRequestForToday())
    private var foods: FetchedResults<Food>
    @State var entry: SimpleEntry
    
    var body: some View {
        VStack {
            Text(entry.date, style: .time)
            if let lastChangeDate = entry.lastChangeDate {
                Text(lastChangeDate, style: .time)
            }
            Text("\(entry.calories) \(todaysCalories())")
        }
    }
    
    func todaysCalories() -> Int {
        return foods.reduce(0) { partialResult, food in
            return partialResult + food.calories.intValue
        }
    }
    
//    var caloriesToday: Int {
//        foods.reduce(0, { lastResult, element in
//            return lastResult + element.calories.intValue
//        })
//    }

    func getFoodCount() -> Int {
        let fetchRequest = NSFetchRequest<Food>(entityName: "Food")
        return try! managedObjectContext.count(for: fetchRequest)
    }
}

//struct CaloriesComplicationView_Previews: PreviewProvider {
//    static var previews: some View {
//        CaloriesComplicationView(calories: 100)
//    }
//}
