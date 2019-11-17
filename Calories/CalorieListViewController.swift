//
//  ViewController.swift
//  Calories
//
//  Created by Bill Gestrich on 12/26/14.
//  Copyright (c) 2014 Bill Gestrich. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
//fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l < r
//  case (nil, _?):
//    return true
//  default:
//    return false
//  }
//}
//
//// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
//// Consider refactoring the code to use the non-optional operators.
//fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l > r
//  default:
//    return rhs < lhs
//  }
//}


class CalorieListViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    var fetchedResultsController:NSFetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultsController = getFetchedResultsController()
        fetchedResultsController.delegate = self
        tableView.register(UINib(nibName: "CalorieTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CalorieCell")

        let backItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem
        navigationController?.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.foregroundColor.rawValue : ThemeKit.titleColor(), NSAttributedString.Key.font.rawValue :  UIFont.systemFont(ofSize: 26.0) ])
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CalorieListViewController.foregroundNotification(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshView()
    }
    
    @objc func foregroundNotification(notification: Notification) {
        self.refreshView()
    }

    
    
    
    
    
    //UITableViewDataSource Delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalorieCell") as! CalorieTableViewCell

        let food = fetchedResultsController.object(at: indexPath) as! Food
        cell.calorieLabel.text = food.name
        cell.numberView.numberValue = food.calories.intValue
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionsArray = sections as Array
            return sectionsArray.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            
            return sections[section].numberOfObjects
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let food = fetchedResultsController.object(at: indexPath) as! Food
        let toPush = self.storyboard?.instantiateViewController(withIdentifier: "detail") as! CalorieDetailViewController
        toPush.food = food        
        navigationController?.pushViewController(toPush, animated: true)
    }
    
    
    
    
    func refreshView(){
        updateFetchRequest(fetchedResultsController.fetchRequest)
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        updateTitle()
        tableView.reloadData()
    }
    
    
    
    
    func updateTitle(){
        var calories = 0.0
        for food in fetchedResultsController.fetchedObjects as! [Food] {
            if let cals = food.calories {
                calories += cals.doubleValue
            }
        }
        
        let calsUsed = NSNumber(value: calories as Double).intValue
        let maxCals = SettingsModel().maxCalorieCount.intValue
        self.navigationItem.title = "\(maxCals - calsUsed)"
    }
    
    
    
    
    
    //NSFetchedResultController Delegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        refreshView()
    }

    
    
    
    
    
    
    
    
    func getFetchedResultsController()->NSFetchedResultsController<NSFetchRequestResult>{
        fetchedResultsController = NSFetchedResultsController(fetchRequest: foodFetchRequest(), managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let managedObject:NSManagedObject = fetchedResultsController.object(at: indexPath) as! NSManagedObject
        DispatchQueue.main.async(execute: { () -> Void in
            self.managedObjectContext?.delete(managedObject)
            do {
                try self.managedObjectContext?.save()
            } catch _ {
            }
        })

    }

    func updateFetchRequest(_ fetchRequest:NSFetchRequest<NSFetchRequestResult>) -> Void {
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: true)
        let predicate = NSPredicate(format: "created > %@", argumentArray: [CalorieAppModel.startOfTodaysLog()])
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
    }
    
    func foodFetchRequest()-> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Food")
        updateFetchRequest(fetchRequest)
        return fetchRequest
    }
    

    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
