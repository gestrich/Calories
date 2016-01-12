//
//  SettingsViewController.swift
//  Calories
//
//  Created by Bill Gestrich on 11/20/15.
//  Copyright © 2015 Bill Gestrich. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var calorieTextField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    
    
    @IBAction func submitTapped(sender: UIButton) {
        if let intNumber = Int(self.calorieTextField.text!) {
            let numberObj = NSNumber(integer: intNumber)
            SettingsModel().maxCalorieCount = numberObj
            NSUbiquitousKeyValueStore.defaultStore().setString("Value \(intNumber)", forKey: "max")
        }
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func cancel(sender : AnyObject){
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let numberObj = SettingsModel().maxCalorieCount
        self.calorieTextField.text = "\(numberObj)"
        self.updateButton.setTitleColor(ThemeKit.baseColor(), forState: UIControlState.Normal)
    
    }
}
