//
//  ContentView.swift
//  Calories
//
//  Created by Bill Gestrich on 8/30/20.
//  Copyright © 2020 Bill Gestrich. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var persistenceManager: PersistenceManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var settings: Settings
    @FetchRequest(fetchRequest: PersistenceManager.foodFetchRequestForToday())
    var foodFetchRequest: FetchedResults<Food>
    @State private var path = NavigationPath()
    
    var body: some View {
        return NavigationStack (path: $path) {
            VStack {
                CalorieListView(path: $path)
                    .padding(.top)
            }.navigationBarItems(
                leading:
                    NavigationLink(destination: {
                        SettingsView()
                    }, label: {
                        settingsButton
                    })
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("\(remainingCalories)")
                        .font(.title)
                        .foregroundColor(Color(ThemeKit.titleColor()))
                        .accessibilityAddTraits(.isHeader)
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    NavigationLink(destination: CalorieEntryView(path: $path, inputContext: .createContext)) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(ThemeKit.buttonTextColor()))
                            .font(.system(size: 20))
                        Text("New Entry")
                            .foregroundColor(Color(ThemeKit.buttonTextColor()))
                    }
                    Spacer()
                }
            }
        }
        .accentColor(Color(uiColor: ThemeKit.baseColor())) //For the back button color to follow the theme.
        .onChange(of: persistenceManager.startOfToday) { newValue in
            $foodFetchRequest.wrappedValue.nsPredicate = PersistenceManager.foodPredicateSinceDate(newValue)
        }
    }
    
    var addEntryButton: some View {
        return Text("New Log Entry")
            .foregroundColor(Color(ThemeKit.buttonTextColor()))
    }
    
    var settingsButton: some View {
        return Image(systemName: "gear")
            .foregroundColor(Color(ThemeKit.buttonTextColor()))
            .font(.system(size: 20.0))
    }
    
    var remainingCalories: Int {
        return remainingCaloriesIn(foods: foodFetchRequest.map({$0}))
    }
    
    func remainingCaloriesIn(foods: [Food]) -> Int {
        let caloriesConsumed = foods.map({$0.calories.intValue}).reduce(0, +)
        let maxCals = settings.maxCalorieCount
        return maxCals - caloriesConsumed
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceManager = PersistenceManager()
        let contentView = ContentView()
            .environment(\.managedObjectContext, persistenceManager.managedObjectContext!)
            .environmentObject(persistenceManager)
        return contentView
    }
}
