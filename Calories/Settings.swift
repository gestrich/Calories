//
//  Settings.swift
//  Calories
//
//  Created by Bill Gestrich on 12/27/14.
//  Copyright (c) 2014 Bill Gestrich. All rights reserved.
//

import Foundation

/*
 Moving to Core Data
 
 CalorieGoal
    minimum: Int
    maximum: Int
    startDate: Date
    endDate: Date
 
 Migration
    If UserDefault exists, add to core data then delete it.
 */

class Settings: NSObject, ObservableObject {
    
    @Published var maxCalorieCount: Int {
        didSet {
            synchronizeMaxCaloriesPrefsWithPublisher()
        }
    }
    
    @Published var experimentalFeaturesUnlocked: Bool {
        didSet {
            synchronizeExperimentalFeaturesUnlockedPrefsWithPublisher()
        }
    }
    
    override init() {
        self.experimentalFeaturesUnlocked = UserDefaults.standard.experimentalFeaturesUnlocked
        self.maxCalorieCount = UserDefaults.standard.maxCalorieCount
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    @objc func defaultsChanged(notication: Notification){
        synchronizeMaxCaloriesPublisherWithPrefs()
        synchronizeExperimentalFeaturesUnlockedPublisherWithPrefs()
    }
    
    private func synchronizeMaxCaloriesPublisherWithPrefs() {
        if maxCalorieCount != UserDefaults.standard.maxCalorieCount {
            maxCalorieCount = UserDefaults.standard.maxCalorieCount
        }
    }
    
    private func synchronizeMaxCaloriesPrefsWithPublisher() {
        if maxCalorieCount != UserDefaults.standard.maxCalorieCount {
            UserDefaults.standard.set(maxCalorieCount, forKey: UserDefaults.standard.maxCalorieCountKey)
        }
    }
    
    private func synchronizeExperimentalFeaturesUnlockedPublisherWithPrefs() {
        if experimentalFeaturesUnlocked != UserDefaults.standard.experimentalFeaturesUnlocked {
            experimentalFeaturesUnlocked = UserDefaults.standard.experimentalFeaturesUnlocked
        }
    }
    
    private func synchronizeExperimentalFeaturesUnlockedPrefsWithPublisher() {
        if experimentalFeaturesUnlocked != UserDefaults.standard.experimentalFeaturesUnlocked {
            UserDefaults.standard.set(experimentalFeaturesUnlocked, forKey: UserDefaults.standard.experimentalFeaturesUnlockedKey)
        }
    }
    
    func remainingCaloriesIn(foods: [Food]) -> Int {
        let caloriesConsumed = foods.map({$0.calories.intValue}).reduce(0, +)
        let maxCals = maxCalorieCount
        return maxCals - caloriesConsumed
    }
}

extension UserDefaults {
    
    var maxCalorieCountKey: String {
        return "test" //key name was used by mistake
    }
    
    var experimentalFeaturesUnlockedKey: String {
        return "experimentalFeaturesUnlocked"
    }
    
    @objc dynamic var maxCalorieCount: Int {
        guard let prefsValue = UserDefaults.standard.value(forKey: maxCalorieCountKey) as? NSNumber else {
            return 2000
        }
        return prefsValue.intValue
    }
    
    @objc dynamic var experimentalFeaturesUnlocked: Bool {
        return UserDefaults.standard.bool(forKey: experimentalFeaturesUnlockedKey)
    }
}
