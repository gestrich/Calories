//
//  PersistenceManager.swift
//  Calories
//
//  Created by Bill Gestrich on 4/24/23.
//  Copyright © 2023 Bill Gestrich. All rights reserved.
//

import Foundation
import CoreData

class PersistenceManager: ObservableObject {
    
    @Published var startOfToday: Date = Date.startOfTodaysLog()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    var cancellable: Any? = nil
    
    init() {
        self.cancellable = timer.sink { _ in
            self.updateStartOfTodayIfNecessary()
        }
    }
    
    func updateStartOfTodayIfNecessary() {
        let updatedStartOfTodaysLog = Date.startOfTodaysLog()
        if updatedStartOfTodaysLog != self.startOfToday {
            self.startOfToday = updatedStartOfTodaysLog
        }
    }

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Calories", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = persistentStoreURL
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        let options = [NSMigratePersistentStoresAutomaticallyOption:true, NSInferMappingModelAutomaticallyOption:true]
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [AnyHashable: Any]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as? [String : Any])
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    private var persistentStoreURL: URL {
        return self.applicationDocumentsDirectory.appendingPathComponent("Calories.sqlite")
    }
    
    private lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.last! as URL
    }()

}


//MARK: Diagnostics

extension PersistenceManager {
    
    func lastWALUpdate() -> Date? {
        return persistentStoreFileNameAndDates()
            .filter({$0.fileName.contains(".sqlite-wal")})
            .last?.modificationDate
    }
    
    func persistentStoreFileNameAndDates() -> [(fileName: String, modificationDate: Date?)] {
        let directoryURL = persistentStoreURL.deletingLastPathComponent()
        
        var toRet = [(String, Date?)]()
        let contents = try! FileManager.default.contentsOfDirectory(atPath: directoryURL.path)
        for fileName in contents {
            let fullURL = directoryURL.appendingPathComponent(fileName, isDirectory: false)
            let attr = try! FileManager.default.attributesOfItem(atPath: fullURL.path)
            guard let modifiedDate = attr[FileAttributeKey.modificationDate] as? Date else {
                continue
            }
            toRet.append((fileName, modifiedDate))
        }

        return toRet
    }
}

//MARK: Food Fetch Requests
extension PersistenceManager {
    
    
    //Fetch Reqeusts
    
    static func foodFetchRequestForToday()-> NSFetchRequest<Food> {
        let fetchRequest = foodAscendingFetchRequest()
        fetchRequest.predicate = todayFetchPredicate()
        return fetchRequest
    }
    
    static func recentFetchRequest() -> NSFetchRequest<Food> {
        let fetchRequest = foodDescendingFetchRequest()
        fetchRequest.predicate = recentFetchPredicate()
        return fetchRequest
    }
    
    static func foodAscendingFetchRequest() -> NSFetchRequest<Food> {
        let fetchRequest = NSFetchRequest<Food>(entityName: foodEntityName)
        let sortDescriptor = NSSortDescriptor(keyPath: \Food.created, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    static func foodDescendingFetchRequest() -> NSFetchRequest<Food> {
        let fetchRequest = NSFetchRequest<Food>(entityName: foodEntityName)
        let sortDescriptor = NSSortDescriptor(keyPath: \Food.created, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    
    // Predicates
    
    static func todayFetchPredicate() -> NSPredicate {
        return foodPredicateSinceDate(Date.startOfTodaysLog())
    }
    
    static func recentFetchPredicate() -> NSPredicate {
        return foodPredicateSinceDate(oldestRecentFoodDate())
    }
    
    static func recentFetchPredicateFiltered(foodName: String) -> NSPredicate {
        return NSPredicate(format: "%K > %@ AND name BEGINSWITH[cd] %@", argumentArray: [#keyPath(Food.created), oldestRecentFoodDate(), foodName])
    }
    
    static func foodPredicateSinceDate(_ date: Date) -> NSPredicate {
        return NSPredicate(format: "%K > %@", argumentArray: [#keyPath(Food.created), date])
    }
    
    
    // Dates
    
    static func oldestRecentFoodDate() -> Date {
        let interval = TimeInterval(-60*60*24*14)
        return Date(timeInterval: interval, since: Date())
    }
    
    
    // Entities
    
    static var foodEntityName: String {
        return "Food"
    }
}
