//
//  CalorieDetailViewController.swift
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
    
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    var fetchedResultsController:NSFetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let food = food {
            foodName.text = food.name
            calories?.text = food.calories.stringValue
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(UINib(nibName: "CalorieTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CalorieCell")
        
        fetchedResultsController = getFetchedResultsController()
        fetchedResultsController.delegate = self
        
        addCustomInputView()
        self.confirmationContainer.alpha = 0.0
        self.addButton.isHidden = true
        
        self.foodName.addTarget(self, action: #selector(CalorieDetailViewController.foodTextChanged(_:)), for:.editingChanged)
        self.calories.addTarget(self, action: #selector(CalorieDetailViewController.foodTextChanged(_:)), for:.editingChanged)
        
        definesPresentationContext = true // for issue http://stackoverflow.com/questions/25032798/uitableview-disappears-when-uisearchcontroller-is-active-and-a-new-tab-is-select
        
        self.topContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CalorieDetailViewController.dismissKeyboard(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshView()
        self.foodName.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func addCustomInputView(){
        let toolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: view.window?.frame.size.width ?? 100.0, height: 44.0))
        toolbar.isTranslucent = false
        toolbar.tintColor = UIColor.black
        toolbar.items = [UIBarButtonItem(title: "   ––", style: UIBarButtonItem.Style.plain, target: self, action: #selector(CalorieDetailViewController.negativeTapped))]
        self.calories?.inputAccessoryView = toolbar
    }
    
    @objc func negativeTapped(){
        if let text = calories?.text {
            if text.hasPrefix("-"){
                calories?.text = text.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.caseInsensitive, range:nil)
            } else {
                calories?.text = "-" + text
            }
        }
        
    }
    
    
    @IBAction func done(_ sender : AnyObject){
        let thisFood = createFood()
        self.refreshTextViews()
        foodName.becomeFirstResponder()
        self.animateLabel(thisFood)
        self.refreshView()
    }
    
    @IBAction func cancel(_ sender : AnyObject){
        dismissViewController()
    }
    
    func refreshTextViews(){
        foodName.text = ""
        calories?.text = ""
        self.searchText = ""
    }
    
    @objc func dismissKeyboard(_ sender : AnyObject){
        calories?.endEditing(true)
        foodName.endEditing(true)
    }
    
    func dismissViewController(){
        if(navigationController?.popViewController(animated: true) == nil){
            NSLog("Error popping view controller");
        }
        
    }
    
    func createFood() -> Food {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Food", in: managedObjectContext!)
        var thisFood : Food
        if food != nil {
            thisFood = food!
            food = nil
        } else {
            thisFood = Food(entity:entityDescription!, insertInto:managedObjectContext)
        }
        
        thisFood.name = foodName?.text
        if let calories = calories {
            let caloriesDouble = NSString(string:calories.text ?? "").doubleValue
            thisFood.calories = NSNumber(value:caloriesDouble)
            thisFood.created = Date()
            do {
                try managedObjectContext?.save()
            } catch _ {
            }
        }
        
        return thisFood
    }
    
    @objc func foodTextChanged(_ sender:UITextField){
        if sender == self.foodName {
            self.searchText = sender.text
        }
        
        self.refreshView()
    }
    
    
    
    //UITableViewDataSource Delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalorieCell") as! CalorieTableViewCell
        let food = fetchedResultsController.object(at: indexPath) as! Food
        cell.calorieLabel.text = food.name
        cell.numberView.numberValue = food.calories.intValue
        cell.accessoryView = UIImageView(image: UIImage(named: "plus"))
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionsArray = sections as Array
            return sectionsArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            
            return sections[section].numberOfObjects
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let oldFood = fetchedResultsController.object(at: indexPath) as! Food
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Food", in: managedObjectContext!)
        let newFood = Food(entity:entityDescription!, insertInto:managedObjectContext)
        
        newFood.name = oldFood.name
        newFood.calories = oldFood.calories
        newFood.created = Date()
        do {
            try managedObjectContext?.save()
        } catch _ {
        }
        
        self.animateLabel(newFood)
        
        self.refreshTextViews()
        
        self.refreshView()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection sectionIndex: Int) -> String? {

        var sectionCalorieCount = 0
        if let sections = fetchedResultsController.sections {
            for rowIndex in 0..<sections[sectionIndex].numberOfObjects {
                let indexPath = IndexPath.init(row: rowIndex, section: sectionIndex)
                let food =  fetchedResultsController.object(at: indexPath) as! Food
                sectionCalorieCount += food.calories.intValue
            }
        }
        let sectionTitle: AnyObject? = fetchedResultsController.sections?[sectionIndex]
        return (sectionTitle?.name ?? "") + "   (\(sectionCalorieCount) cals)"
    }
    
    //UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.dismissKeyboard(self)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //refreshView()
    }
    
    func getFetchedResultsController()->NSFetchedResultsController<NSFetchRequestResult>{
        fetchedResultsController = NSFetchedResultsController(fetchRequest: foodFetchRequest(), managedObjectContext: managedObjectContext!, sectionNameKeyPath: "presentableDate", cacheName: nil)
        return fetchedResultsController
        
    }
    
    func updateFetchRequest(_ fetchRequest:NSFetchRequest<NSFetchRequestResult>) -> Void {
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: false)
        let interval = TimeInterval(-60*60*24*14)
        let date = Date(timeInterval: interval, since: Date())
        let predicate : NSPredicate
        let foodText = self.foodName.text
        if foodText != nil && foodText?.lengthOfBytes(using: String.Encoding.utf8) != 0 {
            
            predicate = NSPredicate(format: "created > %@ AND name BEGINSWITH[cd] %@", argumentArray: [date, "\(foodText!)"])
        } else {
            predicate = NSPredicate(format: "created > %@", argumentArray: [date])
        }
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
    }
    
    func foodFetchRequest()-> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Food")
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
        let foodLetterCount = self.foodName.text?.count ?? 0
        let caloriesLetterCount = self.calories?.text?.count ?? 0
        if foodLetterCount > 0 && caloriesLetterCount > 0 {
            self.addButton.isHidden = false
        } else {
            self.addButton.isHidden = true
        }
    }
    
    func animateLabel(_ food : Food){
        self.confirmationLabel.text = " \(food.name!) \(food.calories!) calories"
        
        self.confirmationContainer.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.confirmationContainer.alpha = 1.0
            }, completion: { (Bool) -> Void in
                UIView.animate(withDuration: 2.0, animations: { () -> Void in
                    self.confirmationContainer.alpha = 0.0
                })
        }) 
    }
}
