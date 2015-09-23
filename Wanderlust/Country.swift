//
//  Country.swift
//  QuandlPractice
//
//  Created by Michael Nichols on 9/4/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Country)

class Country: NSManagedObject {
    
    @NSManaged var countryName: NSNumber
    @NSManaged var countryData: [String: [String: String]]
    @NSManaged var countryFlag: UIImage
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(name: String, data: [String: [String: String]], flag: UIImage) {
        
        // Core data
        let entity = NSEntityDescription.entityForName("Country", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        countryName = name
        countryData = data
        countryFlag = flag
        
    }
    
    // variable to adhere to MKAnnotation - to be able to call up 2d coords
    var flagPhoto: UIImage {
        return flag
    }
    
    
}