//
//  CalorieDetailViewController.swift
//  Calories
//
//  Created by Bill Gestrich on 12/26/14.
//  Copyright (c) 2014 Bill Gestrich. All rights reserved.
//

import UIKit

class CalorieDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet var foodName : UITextField!
    @IBOutlet var calories : UITextField!
    @IBOutlet var tableView : UITableView!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var confirmationLabel: UILabel!
    @IBOutlet weak var confirmationContainer: UIView!
    @IBOutlet weak var addButton: UIButton!
    
    var food : Food?
    var searchText : String?
    
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var fetchedResultsController:NSFetchedResultsController = NSFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let food = food {
            foodName.text = food.name
            calories?.text = food.calories.stringValue
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.registerNib(UINib(nibName: "CalorieDetailTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "DetailCell")
        
        fetchedResultsController = getFetchedResultsController()
        fetchedResultsController.delegate = self
        
        addCustomInputView()
        self.confirmationContainer.alpha = 0.0
        self.addButton.hidden = true
        
        self.foodName.addTarget(self, action: Selector("foodTextChanged:"), forControlEvents:.EditingChanged)
        self.calories.addTarget(self, action: Selector("foodTextChanged:"), forControlEvents:.EditingChanged)
        
        definesPresentationContext = true // for issue http://stackoverflow.com/questions/25032798/uitableview-disappears-when-uisearchcontroller-is-active-and-a-new-tab-is-select
        
        self.topContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
    }
    
    override func viewWillAppear(animated: Bool) {
        self.refreshView()
        self.foodName.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func addCustomInputView(){
        let toolbar = UIToolbar(frame: CGRectMake(0.0, 0.0, view.window?.frame.size.width ?? 100.0, 44.0))
        toolbar.translucent = false
        toolbar.tintColor = UIColor.blackColor()
        toolbar.items = [UIBarButtonItem(title: "   ––", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("negativeTapped"))]
        self.calories?.inputAccessoryView = toolbar
    }
    
    func negativeTapped(){
        if let text = calories?.text {
            if text.hasPrefix("-"){
                calories?.text = text.stringByReplacingOccurrencesOfString("-", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range:nil)
            } else {
                calories?.text = "-" + text
            }
        }
        
    }
    
    
    @IBAction func done(sender : AnyObject){
        let thisFood = createFood()
        self.refreshTextViews()
        foodName.becomeFirstResponder()
        self.animateLabel(thisFood)
        self.refreshView()
    }
    
    @IBAction func cancel(sender : AnyObject){
        dismissViewController()
    }
    
    func refreshTextViews(){
        foodName.text = ""
        calories?.text = ""
        self.searchText = ""
    }
    
    func dismissKeyboard(sender : AnyObject){
        calories?.endEditing(true)
        foodName.endEditing(true)
    }
    
    func dismissViewController(){
        navigationController?.popViewControllerAnimated(true)
    }
    
    func createFood() -> Food {
        let entityDescription = NSEntityDescription.entityForName("Food", inManagedObjectContext: managedObjectContext!)
        var thisFood : Food
        if food != nil {
            thisFood = food!
        } else {
            thisFood = Food(entity:entityDescription!, insertIntoManagedObjectContext:managedObjectContext)
        }
        
        thisFood.name = foodName?.text
        if let calories = calories {
            let caloriesDouble = NSString(string:calories.text!).doubleValue
            thisFood.calories = caloriesDouble
            thisFood.created = NSDate()
            do {
                try managedObjectContext?.save()
            } catch _ {
            }
        }
        
        return thisFood
    }
    
    func foodTextChanged(sender:UITextField){
        if sender == self.foodName {
            self.searchText = sender.text
        }
        
        self.refreshView()
    }
    
    
    
    //UITableViewDataSource Delegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell") as! CalorieDetailTableViewCell
        let food = fetchedResultsController.objectAtIndexPath(indexPath) as! Food
        cell.textLabel?.text = food.name
        cell.detailTextLabel?.text = food.calories.stringValue
        cell.accessoryView = UIImageView(image: UIImage(named: "plus"))
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionsArray = sections as Array
            return sectionsArray.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            
            return sections[section].numberOfObjects
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let oldFood = fetchedResultsController.objectAtIndexPath(indexPath) as! Food
        
        let entityDescription = NSEntityDescription.entityForName("Food", inManagedObjectContext: managedObjectContext!)
        let newFood = Food(entity:entityDescription!, insertIntoManagedObjectContext:managedObjectContext)
        
        newFood.name = oldFood.name
        newFood.calories = oldFood.calories
        newFood.created = NSDate()
        do {
            try managedObjectContext?.save()
        } catch _ {
        }
        
        self.animateLabel(newFood)
        
        self.refreshTextViews()
        
        self.refreshView()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionTitle: AnyObject? = fetchedResultsController.sections?[section]
        return sectionTitle?.name
    }
    
    //UIScrollViewDelegate
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.dismissKeyboard(self)
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        //refreshView()
    }
    
    func getFetchedResultsController()->NSFetchedResultsController{
        fetchedResultsController = NSFetchedResultsController(fetchRequest: foodFetchRequest(), managedObjectContext: managedObjectContext!, sectionNameKeyPath: "presentableDate", cacheName: nil)
        return fetchedResultsController
        
    }
    
    func updateFetchRequest(fetchRequest:NSFetchRequest) -> Void {
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: false)
        let interval = NSTimeInterval(-60*60*24*14)
        let date = NSDate(timeInterval: interval, sinceDate: NSDate())
        let predicate : NSPredicate
        let foodText = self.foodName.text
        if foodText != nil && foodText?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0 {
            
            predicate = NSPredicate(format: "created > %@ AND name BEGINSWITH[cd] %@", argumentArray: [date, "\(foodText!)"])
        } else {
            predicate = NSPredicate(format: "created > %@", argumentArray: [date])
        }
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
    }
    
    func foodFetchRequest()-> NSFetchRequest {
        let fetchRequest =  NSFetchRequest(entityName: "Food")
        updateFetchRequest(fetchRequest)
        return fetchRequest
    }
    
    func refreshView(){
        updateFetchRequest(fetchedResultsController.fetchRequest)
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        tableView.reloadData()
        if self.foodName.text?.characters.count > 0 && self.calories?.text?.characters.count > 0 {
            self.addButton.hidden = false
        } else {
            self.addButton.hidden = true
        }
    }
    
    func animateLabel(food : Food){
        self.confirmationLabel.text = " \(food.name) \(food.calories) calories"
        
        self.confirmationContainer.alpha = 0.0
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.confirmationContainer.alpha = 1.0
            }) { (Bool) -> Void in
                UIView.animateWithDuration(2.0, animations: { () -> Void in
                    self.confirmationContainer.alpha = 0.0
                })
        }
    }
}
