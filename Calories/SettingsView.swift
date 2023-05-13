//
//  SettingsView.swift
//  Calorie Log
//
//  Created by Bill Gestrich on 4/28/23.
//  Copyright © 2023 Bill Gestrich. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

struct SettingsView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var settings: Settings
    @State var maxCaloriesInput: String = ""
    @FocusState var maxCaloriesInputFocused: Bool
    @State var deleteAllConfirmationShowing: Bool = false
    
    @FetchRequest(fetchRequest: SettingsView.foodFetchRequest())
    private var foods: FetchedResults<Food>
    
    var body: some View {
        Form {
            Section {
                LabeledContent("Max Calories") {
                    HStack {
                        TextField("Calories", text: $maxCaloriesInput)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .focused($maxCaloriesInputFocused)
                            .foregroundColor(Color(ThemeKit.baseColor()))
                    }
                }
                .onTapGesture {
                    maxCaloriesInputFocused.toggle()
                }
                .onChange(of: maxCaloriesInputFocused) { newValue in
                    saveMaxCalories()
                }
            }
            Section("About") {
                LabeledContent("Developer") {
                    Text("Bill Gestrich (2023)")
                }.simultaneousGesture(LongPressGesture(minimumDuration: 1.5).onEnded { _ in
                    settings.experimentalFeaturesUnlocked = !settings.experimentalFeaturesUnlocked
                })
            }
            if settings.experimentalFeaturesUnlocked {
                Section("Diagnostics") {
                    LabeledContent("Records") {
                        Text("\(getFoodCount())")
                    }
                    if let firstFood = getFirstRecord() {
                        LabeledContent("Start Date") {
                            Text(firstFood.created.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                    Button("Delete All", role: .destructive) {
                        deleteAllConfirmationShowing = true
                    }.confirmationDialog("Delete All?", isPresented: $deleteAllConfirmationShowing) {
                        Button("Delete all items?", role: .destructive) {
                            deleteAllRecords()
                        }
                    }
                }
            }

        }
        .navigationTitle("Settings")
        .onAppear() {
            maxCaloriesInput = "\(settings.maxCalorieCount)"
        }
    }
    
    func saveMaxCalories() {
        guard let intValue = Int(maxCaloriesInput), intValue != settings.maxCalorieCount else {
            return
        }
        
        settings.maxCalorieCount = intValue
    }
    
    //TODO: Move these fetch requests to PersistentManager
    
    func deleteAllRecords(){
        let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Food")
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.returnsObjectsAsFaults = true
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                managedObjectContext.delete(objectData)
            }
            try managedObjectContext.save()
        } catch let error {
            print(error)
        }
    }
    
    func getFoodCount() -> Int {
        let fetchRequest = NSFetchRequest<Food>(entityName: "Food")
        return try! managedObjectContext.count(for: fetchRequest)
    }
    
    func getFirstRecord() -> Food? {
        let fetchRequest = NSFetchRequest<Food>(entityName: "Food")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created", ascending: true)]
        fetchRequest.fetchLimit = 1
        return try? managedObjectContext.fetch(fetchRequest).first
    }
    
    static func foodFetchRequest()-> NSFetchRequest<Food> {
        let fetchRequest =  NSFetchRequest<Food>(entityName: "Food")
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
}
