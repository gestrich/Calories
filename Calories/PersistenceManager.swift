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
    private let appGroup: String?
    
    init(appGroup: String?) {
        self.appGroup = appGroup
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

    lazy var managedObjectContext: NSManagedObjectContext = {
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return persistentContainer.viewContext
    }()
    
    private lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: appModelName)
        container.persistentStoreDescriptions = [persistenStoreDescription]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private lazy var persistenStoreDescription: NSPersistentStoreDescription = {
        let description = NSPersistentStoreDescription(url: persistentStoreURL)
        let cloudkitOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: iCloudContainerIdentifier)
        description.cloudKitContainerOptions = cloudkitOptions
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        return description
    }()
    
    private var persistentStoreURL: URL {
        if let appGroup {
            guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
                fatalError("Shared file container could not be created.")
            }
            return fileContainer.appendingPathComponent(appModelName).appendingPathExtension("sqlite")
        } else {
            return self.applicationDocumentsDirectory.appendingPathComponent(appModelName).appendingPathExtension("sqlite")
        }
    }
    
    private var appModelName: String {
        return "Calories"
    }
    
    private var iCloudContainerIdentifier: String {
        return "iCloud.org.gestrich.calorie-log"
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
