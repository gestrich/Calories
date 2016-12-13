//
//  CalorieTableViewCell.swift
//  Calories
//
//  Created by Bill Gestrich on 11/16/15.
//  Copyright © 2015 Bill Gestrich. All rights reserved.
//

import UIKit

class CalorieTableViewCell: UITableViewCell {

    @IBOutlet weak var numberView: NumberView!
    @IBOutlet weak var calorieLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
