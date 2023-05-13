//
//  CalorieListView.swift
//  Calories
//
//  Created by Bill Gestrich on 8/30/20.
//  Copyright © 2020 Bill Gestrich. All rights reserved.
//

import SwiftUI
import CoreData

struct CalorieListView: View {
 
    @EnvironmentObject var persistenceManager: PersistenceManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: PersistenceManager.foodFetchRequestForToday())
    var foodFetchRequest: FetchedResults<Food>
    @Binding var path: NavigationPath

    var body: some View {
        return VStack {
            List {
                ForEach(foodFetchRequest, id: \.id) { food in
                    NavigationLink(value: food) {
                        CalorieRowView(name: food.name, calories: food.calories.intValue, shouldShowAddButton: false)
                    }
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .leading) {
                        Button {
                            cloneFood(food)
                        } label: {
                            Label("Add", systemImage: "plus.circle")
                        }
                        .tint(Color(uiColor: ThemeKit.baseColor()))
                    }
                }
                .onDelete { indexSet in
                    delete(foods: foodFetchRequest.map({$0}), at: indexSet)
                }
            }
            .listStyle(.plain)
            .navigationDestination(for: Food.self, destination: { food in
                CalorieEntryView(path: $path, inputContext: .editContext(food: food))
            })
        }
        .onChange(of: persistenceManager.startOfToday) { newValue in
            $foodFetchRequest.wrappedValue.nsPredicate = PersistenceManager.foodPredicateSinceDate(newValue)
        }
    }
    
    func cloneFood(_ foodToClone: Food) {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Food", in: managedObjectContext)
        let food = Food(entity:entityDescription!, insertInto:managedObjectContext)
        food.created = Date()
        food.name = foodToClone.name
        food.calories = foodToClone.calories
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Error cloning food: \(error)")
        }
    }

    func delete(foods: [Food], at offsets:IndexSet){
        offsets.map { foods[$0]}.forEach { food in
            managedObjectContext.delete(food)
            do {
                try managedObjectContext.save()
            } catch {
                print("Error deleting food \(food), \(error)")
            }
        }
    }
}




struct CalorieListView_Previews: PreviewProvider {
    
    static var previews: some View {
        var path = NavigationPath()
        let pathBinding: Binding<NavigationPath> = Binding {
            return path
        } set: { updatedPath in
            path = updatedPath
        }

        CalorieListView(path: pathBinding)
    }
}
