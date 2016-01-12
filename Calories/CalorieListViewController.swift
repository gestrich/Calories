//
//  ViewController.swift
//  Calories
//
//  Created by Bill Gestrich on 12/26/14.
//  Copyright (c) 2014 Bill Gestrich. All rights reserved.
//

import UIKit

class CalorieListViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var fetchedResultsController:NSFetchedResultsController = NSFetchedResultsController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultsController = getFetchedResultsController()
        fetchedResultsController.delegate = self
        tableView.registerNib(UINib(nibName: "CalorieTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "CalorieCell")

        let backItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : ThemeKit.titleColor(), NSFontAttributeName :  UIFont.systemFontOfSize(26.0) ]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        refreshView()
    }

    
    
    
    
    
    //UITableViewDataSource Delegate
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("CalorieCell") as! CalorieTableViewCell

        let food = fetchedResultsController.objectAtIndexPath(indexPath) as! Food
        cell.calorieLabel.text = food.name
        cell.numberView.numberValue = food.calories.integerValue
        
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionsArray = sections as Array
            return sectionsArray.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            
            return sections[section].numberOfObjects
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let food = fetchedResultsController.objectAtIndexPath(indexPath) as! Food
        let toPush = self.storyboard?.instantiateViewControllerWithIdentifier("detail") as! CalorieDetailViewController
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
        
        let calsUsed = NSNumber(double: calories).integerValue
        let maxCals = SettingsModel().maxCalorieCount.integerValue
        self.navigationItem.title = "\(calsUsed) / \(maxCals - calsUsed)"
    }
    
    
    
    
    
    //NSFetchedResultController Delegate
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        refreshView()
    }

    
    
    
    
    
    
    
    
    func getFetchedResultsController()->NSFetchedResultsController{
        fetchedResultsController = NSFetchedResultsController(fetchRequest: foodFetchRequest(), managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let managedObject:NSManagedObject = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.managedObjectContext?.deleteObject(managedObject)
            do {
                try self.managedObjectContext?.save()
            } catch _ {
            }
        })

    }

    func updateFetchRequest(fetchRequest:NSFetchRequest) -> Void {
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: true)
        let today = NSDate()
        let gregorian = NSCalendar(identifier: NSCalendarIdentifierGregorian)

        let todayComponents = gregorian?.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour], fromDate: today)
    
        let localStartHour = 3
        if (gregorian?.timeZone.isDaylightSavingTimeForDate(today) != nil) {
            todayComponents?.hour = localStartHour
        } else {
            todayComponents?.hour = localStartHour + 1
        }
        
        if let todayComponents = todayComponents {
            var startDate = gregorian?.dateFromComponents(todayComponents)
            if startDate?.timeIntervalSince1970 > NSDate().timeIntervalSince1970 {
                //Start time in future, use yesterday's start hour
                startDate = startDate?.dateByAddingTimeInterval(-60*60*24)
            }
            let predicate = NSPredicate(format: "created > %@", argumentArray: [startDate!])
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
    }
    
    func foodFetchRequest()-> NSFetchRequest {
        let fetchRequest =  NSFetchRequest(entityName: "Food")
        updateFetchRequest(fetchRequest)
        return fetchRequest
    }
    

    
}

