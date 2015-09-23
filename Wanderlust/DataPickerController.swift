//
//  DataPickerController.swift
//  Wanderlust
//
//  Created by Michael Nichols on 8/26/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataPickerController: UIViewController, UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var queryResult: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var countryFlag: UIImageView!
    @IBOutlet weak var yearOfData: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    var country: Country?
    var networkAccess = false
    
    let pickerData = WorldBank.INDICATORS.QUERY_CHOICES
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting the picker view's data source and delegate
        pickerView.dataSource = self
        pickerView.delegate = self
        
        // Hiding the activity indicator
        activity.hidden = true
        
        // Checking for network access
        networkAccess = Connectivity.isConnectedToNetwork()
        
        // Grabbing the chosen country
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        country = appDelegate.pickedCountry!
        
        // Setting country name
        countryLabel.text = country!.countryName
        
        // If there is an image cached, grab it. Otherwise, fetch from Wikipedia.
        if let image = country?.flagImage {
            countryFlag.image = image
        } else {
            getFlagPhotoFromWiki()
        }
        
        // Setting the initial text to display
        queryResult.text = WorldBank.COUNTRIES.DATA[country!.countryName]!["Capital"]!
        
        // If there is data, load it. Otherwise, to get it from Worldbank
        if let _ = country!.population {
            country!.buildCountryData()
        } else {
            if networkAccess {
                getDataFromWorldBank()
            } else {
                let alert = UIAlertController(title: "No Network Access", message: "To obtain data from the Worldbank, you need to have a network connection. Please connect to a network and try again.", preferredStyle: .Alert)
                
                let cancel = UIAlertAction(title: "OK", style: .Cancel, handler: {(action) -> Void in})
                alert.addAction(cancel)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        
    }
    
    // Hiding the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //MARK: Delegates for picker view
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let picked = pickerData[row]
        
        // If picked is manual data, grab it. Otherwise, grab from saved data.
        switch (picked) {
            case "Religion":
                self.queryResult.text = WorldBank.COUNTRIES.DATA[country!.countryName]!["Religion"]!
            case "Language":
                self.queryResult.text = WorldBank.COUNTRIES.DATA[country!.countryName]!["Language"]!
            case "Capital":
                self.queryResult.text = WorldBank.COUNTRIES.DATA[country!.countryName]!["Capital"]!
            case "Currency":
                self.queryResult.text = WorldBank.COUNTRIES.DATA[country!.countryName]!["Currency"]!
            default:
                let dataResult = country!.countryData[picked]!
                queryResult.text = Helper.sharedInstance().formatResult(picked, result: dataResult.0)!
                yearOfData.text = "Data as of \(dataResult.1)"
            
            }
        
    }
    
    // Formatting picker view text.
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        return myTitle
    }
    
    // Helper function to grab country flag photo from Wikipedia and cache it.
    func getFlagPhotoFromWiki() {
        if let country = country {
            Wiki.sharedInstance().getWikiData(country.countryName) {result, error in
            
                if let error = error {
                    print(error)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.countryFlag.image = result as? UIImage
                        self.country?.flagImage = result as? UIImage
                        self.saveContext()
                    }
                }
            }
        }
    }
    
    // Helper function to grab all data and all indicators from Worldbank.
    func getDataFromWorldBank() {
        activity.hidden = false
        queryResult.hidden = true
        activity.startAnimating()
        for indicator in WorldBank.INDICATORS.QUERY_CHOICES {
            if indicator != "Language" && indicator != "Religion" && indicator != "Currency" && indicator != "Capital" {
                let chosenIndicator = WorldBank.INDICATORS.QUERY_DICTIONARY[indicator]
                
                WorldBank.sharedInstance().getWBData(country!.countryCode, indicator: chosenIndicator!) { JSONResult, error in
                    if let error = error {
                        print(error)
                    } else {
                        _ = Helper.sharedInstance().formatResult(indicator, result: JSONResult.0)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.country?.addToCountryData(indicator, result: JSONResult)
                            self.saveContext()
                        }
                    }
                }
            }
        }
        activity.stopAnimating()
        activity.hidden = true
        queryResult.hidden = false

    }
    
    // Helper property to access CoreDataStack
    var sharedContext: NSManagedObjectContext {
        return CoreDataStack.sharedInstance().managedObjectContext!
    }
    
    // Helper function to save the context after key changes
    func saveContext() {
        CoreDataStack.sharedInstance().saveContext()
    }
    
    // Helper function to delete the country data upon refresh.
    func deleteCountryData(country: Country) {
        country.rebuildCountryData()
        saveContext()
    }
    
    // Segue to Wikipedia webview.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toWikiVC" {
            
            let controller = segue.destinationViewController as!
            WikiWebview
                
            var URL = String()
                
            // Getting the URL
            URL = Wiki.sharedInstance().createWikiURL(country!.countryName)
            controller.URL = NSURL(string: URL)
        }
    }
    
    // Segue to wiki webview.
    @IBAction func toWiki(sender: UIButton) {
    
        self.performSegueWithIdentifier("toWikiVC", sender: self)
        
    }
    
    // Refresh data from Worldbank.
    @IBAction func refreshData(sender: UIBarButtonItem) {
        deleteCountryData(country!)
        getDataFromWorldBank()
    }
    
    @IBAction func dismissView(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}