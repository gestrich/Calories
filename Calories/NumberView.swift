//
//  NumberView.swift
//  Calories
//
//  Created by Bill Gestrich on 11/9/15.
//  Copyright © 2015 Bill Gestrich. All rights reserved.
//

import UIKit

@IBDesignable class NumberView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
    }
    
    var numberValue : Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        ThemeKit.baseColor().setFill()
        let path = UIBezierPath(ovalInRect: self.bounds)
        path.closePath()
        path.fill()
        
        let string = NSAttributedString(string: "\(numberValue)", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        
        let xPos = CGRectGetMidX(self.bounds) - string.size().width/2
        let yPos = CGRectGetMidY(self.bounds) - string.size().height/2
        string.drawAtPoint(CGPointMake (xPos, yPos))
    }
    
    override func prepareForInterfaceBuilder() {
        self.numberValue = 250
    }
}

