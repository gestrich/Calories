//
//  ContentView.swift
//  CaloriesWatchApp
//
//  Created by Bill Gestrich on 4/24/23.
//  Copyright © 2023 Bill Gestrich. All rights reserved.
//

import SwiftUI
import CoreData
import WidgetKit

struct ContentView: View {
    
    @EnvironmentObject var persistenceManager: PersistenceManager
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(fetchRequest: PersistenceManager.foodFetchRequestForToday())
    private var foods: FetchedResults<Food>
    
    @FetchRequest(fetchRequest: PersistenceManager.foodAscendingFetchRequest())
    private var allFoods: FetchedResults<Food>
    
    @ObservedObject private var connectivityManager = WatchConnectivityManager.shared
    
    @State var foodNameInputText: String = ""
    @State var caloriesInputText: String = ""
    @State var lastWALUpdate: Date?
    @State var lastIPhoneUpdateDate: Date?
    
    @State var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                List {
                    Text("\(Settings().remainingCaloriesIn(foods: foods.map({$0})))")
                    Text("Count: \(allFoods.count)")
                    ForEach(foods) { food in
                        HStack {
                            Text(food.name)
                            Spacer()
                            Text("\(food.calories)")
                        }
                    }
                    .onDelete { indexSet in
                        delete(foods: foods.map({$0}), at: indexSet)
                    }
                    NavigationLink(value: "EntryForm") {
                        Text("Add")
                    }
                    Button("Refresh Dates") {
                        lastWALUpdate = persistenceManager.lastWALUpdate()
                    }
                    Text("WAL: \(String.init(describing:lastWALUpdate))")
                    Text("IPhone Update: \(String.init(describing:lastIPhoneUpdateDate))")
                    Button("Reload Widget") {
                        reloadWidget()
                    }
                }
            }.onChange(of: connectivityManager.notificationMessage) { newValue in
                reloadWidget()
                lastIPhoneUpdateDate = Date()
            }
            .onAppear {
                _lastWALUpdate.wrappedValue = persistenceManager.lastWALUpdate()
            }
            .navigationDestination(for: String.self) { _ in
                Form {
                    TextField("Food", text: $foodNameInputText)
                    TextField("Calories", text: $caloriesInputText)
                    Button("Save") {
                        saveFoodEntry()
                        reloadWidget()
                        path.removeLast()
                    }
                }
            }
        }
    }
    
    func saveFoodEntry() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Food", in: managedObjectContext)
        
        let food = Food(entity:entityDescription!, insertInto:managedObjectContext)
        food.created = Date()
        food.name = foodNameInputText
        guard let calories = Int(caloriesInputText) else {
            return
        }
        
        food.calories = NSNumber(integerLiteral: calories)
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving food: \(error)")
        }
    }
    
    func saveTestFoodEntry() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Food", in: managedObjectContext)
        
        let food = Food(entity:entityDescription!, insertInto:managedObjectContext)
        food.created = Date()
        food.name = "Test"
        food.calories = NSNumber(integerLiteral: 1)
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving food: \(error)")
        }
    }
    
    func reloadWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "CaloriesWatchExtension")
    }
    
    func delete(foods: [Food], at offsets:IndexSet){
        offsets.map { foods[$0]}.forEach { food in
            delete(food: food)
        }
    }
    
    func delete(food: Food) {
        managedObjectContext.delete(food)
        do {
            try managedObjectContext.save()
        } catch {
            print("Error deleting food \(food), \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        ContentView()
    }
}
