//
//  CountryTableCell.swift
//  Wanderlust
//
//  Created by Michael Nichols on 9/11/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation
import UIKit

class CountryTableCell : UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView!.frame = CGRectMake(5,5,65,32.5)
        
        self.textLabel?.adjustsFontSizeToFitWidth = true
        self.textLabel?.font = UIFont.systemFontOfSize(20)
        self.textLabel?.textColor = UIColor.init(red: 59/256, green: 139/256, blue: 148/256, alpha: 1.0)
        
        self.textLabel?.frame = CGRectMake(85, 12.5, (self.textLabel?.frame.width)!, 20)
        self.separatorInset.left = 80
    }
    
}