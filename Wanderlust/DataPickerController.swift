//
//  DataPickerController.swift
//  QuandlPractice
//
//  Created by Michael Nichols on 8/26/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation
import UIKit

class DataPickerController: UIViewController, UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var queryResult: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var countryFlag: UIImageView!
    @IBOutlet weak var yearOfData: UILabel!
    var country: String?
    var code: String?
    
    let pickerData = WorldBank.INDICATORS.QUERY_CHOICES
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        country = appDelegate.country
        code = appDelegate.code
        
        if let country = country {
            countryLabel.text = country
            getFlagPhotoFromWiki()
        }
        
        queryResult.text = WorldBank.COUNTRIES.DATA[country!]!["Language"]!
        
        navigationController?.navigationBarHidden = false
        
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let picked = pickerData[row]
        
        switch (picked) {
            case "Religion":
                self.queryResult.text = WorldBank.COUNTRIES.DATA[country!]!["Religion"]!
            case "Language":
                self.queryResult.text = WorldBank.COUNTRIES.DATA[country!]!["Language"]!
            case "Capital":
                self.queryResult.text = WorldBank.COUNTRIES.DATA[country!]!["Capital"]!
            case "Currency":
                self.queryResult.text = WorldBank.COUNTRIES.DATA[country!]!["Currency"]!
            default:
                let chosenIndicator = WorldBank.INDICATORS.QUERY_DICTIONARY[picked]
                
                WorldBank.sharedInstance().getWBData(code!, indicator: chosenIndicator!) { JSONResult, error in
                    if let error = error {
                        println(error)
                    } else {
                        var countryData = Helper.sharedInstance().formatResult(picked, result: JSONResult.0)
                        println(JSONResult)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.queryResult.text = countryData
                            self.yearOfData.text = "Data as of \(JSONResult.1)"
                        }
                    }
            }
        }
        
        
    }
    
        
    func getFlagPhotoFromWiki() {
        if let country = country {
            Wiki.sharedInstance().getWikiData(country) {result, error in
            
                if let error = error {
                    println(error)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.countryFlag.image = result as? UIImage
                    }
                }
            }
        }
    }
    
    
}