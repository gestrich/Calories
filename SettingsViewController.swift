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
    
    
    @IBAction func submitTapped(_ sender: UIButton) {
        if let intNumber = Int(self.calorieTextField.text!) {
            let numberObj = NSNumber(value: intNumber as Int)
            SettingsModel().maxCalorieCount = numberObj
            NSUbiquitousKeyValueStore.default().set("Value \(intNumber)", forKey: "max")
        }
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func cancel(_ sender : AnyObject){
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let numberObj = SettingsModel().maxCalorieCount
        self.calorieTextField.text = "\(numberObj)"
        self.updateButton.setTitleColor(ThemeKit.baseColor(), for: UIControlState())
    
    }
}
