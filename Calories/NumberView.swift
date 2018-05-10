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
        self.backgroundColor = UIColor.clear
    }
    
    var numberValue : Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        ThemeKit.baseColor().setFill()
        let path = UIBezierPath(ovalIn: self.bounds)
        path.close()
        path.fill()
        
        let string = NSAttributedString(string: "\(numberValue)", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor):UIColor.white]))
        
        let xPos = self.bounds.midX - string.size().width/2
        let yPos = self.bounds.midY - string.size().height/2
        string.draw(at: CGPoint (x: xPos, y: yPos))
    }
    
    override func prepareForInterfaceBuilder() {
        self.numberValue = 250
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
