//
//  MapViewController.swift
//  Wanderlust
//
//  Created by Michael Nichols on 8/25/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    var countryNames: [String]!
    var countryToPass: Country!
    var networkAccess = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        
        networkAccess = Connectivity.isConnectedToNetwork()
        
        // Gesture recognizer and assign locateCountry method to it
        let longTapAndHoldGesture = UILongPressGestureRecognizer(target: self, action: "locateCountry:")
        
        map.addGestureRecognizer(longTapAndHoldGesture)
        
        // Hiding the navbar
        navigationController?.navigationBarHidden = true
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBarHidden = false
    }
    
    // A function to reverse locate the country name based on the location of the tap and hold gesture
    func reverseLocate(lat: CLLocationDegrees, lon: CLLocationDegrees, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        let geocoder = CLGeocoder()
        // var manager : CLLocationManager!
        let longitude = lon
        let latitude = lat
        
        let location = CLLocation(latitude: latitude, longitude: longitude) //changed!!!
        
        // Check for network access before allowing data call to Worldbank API.
        if networkAccess {
        
            geocoder.reverseGeocodeLocation(location) {(placemarks, error) -> Void in

                let placeArray = placemarks //as? [CLPlacemark]
            
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placeArray?[0]
            
                // Country
                if let country = placeMark.country  {
                    completionHandler(result: country, error: nil)
                } else {
                    completionHandler(result: "Not a country", error: NSError(domain: "Location", code: 0, userInfo: [NSLocalizedDescriptionKey: "Location Error"]))
                }
            }
        } else {
            let alert = UIAlertController(title: "No Network Access", message: "To obtain data from the Worldbank, you need to have a network connection. Please connect to a network and try again.", preferredStyle: .Alert)
                
            let cancel = UIAlertAction(title: "OK", style: .Cancel, handler: {(action) -> Void in})
                alert.addAction(cancel)
                
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // Hiding the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // A function to locate the country on the map if a long tap and hold occurs
    func locateCountry(gesture: UIGestureRecognizer) {
        
        if gesture.state == .Began {
            
            // Grabbing coords
            let point = gesture.locationInView(map)
            let locCoord = map.convertPoint(point, toCoordinateFromView: map)
            
            reverseLocate(locCoord.latitude, lon: locCoord.longitude) {result, error in
            
                if let newCountry = result as? String {
                    if Helper.sharedInstance().inDictionary(newCountry, dictionary: WorldBank.COUNTRIES.DATA) {
                        // Create the country if not already a saved country - otherwise, move to the data view.
                        if !self.countrySaved(newCountry) {
                            let country = Country(name: newCountry, context: self.sharedContext)
                            self.saveContext()
                            self.createAppDelegateObject(country)
                        } else {
                            let country = self.countryToPass
                            self.createAppDelegateObject(country)
                        }
                        self.toPickerView()
                    } else {
                        let alert = UIAlertController(title: newCountry, message: "The tapped item was not a country. Please tap and hold on a country.", preferredStyle: .Alert)
                        
                        let cancel = UIAlertAction(title: "OK", style: .Cancel, handler: {(action) -> Void in})
                        alert.addAction(cancel)
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                } else {
                    let alert = UIAlertController(title: "Download Error", message: "The download failed.", preferredStyle: .Alert)
                    
                    let cancel = UIAlertAction(title: "OK", style: .Cancel, handler: {(action) -> Void in})
                    alert.addAction(cancel)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    // Helper function to push the view to the DataPickerVC
    func toPickerView() {
        self.performSegueWithIdentifier("toDataVC", sender: self)
    }
    
    // Helper property to access CoreDataStack
    var sharedContext: NSManagedObjectContext {
        return CoreDataStack.sharedInstance().managedObjectContext!
    }
    
    // Helper function to save the context after key changes
    func saveContext() {
        CoreDataStack.sharedInstance().saveContext()
    }
    
    // Helper function to create and save the app delegate object to pass on between controllers
    func createAppDelegateObject(country: Country) {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.pickedCountry = country
    }
    
    // Fetching all the countries to determine if there is already data for a country.
    func fetchAllCountries() -> [Country] {
        let error: NSErrorPointer = nil
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Country")
        
        // Execute the Fetch Request
        let results: [AnyObject]?
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error.memory = error1
            results = nil
        }
        
        // Check for Errors
        if error != nil {
            let alert = UIAlertController(title: "Fetch Error", message: "The data fetch failed.", preferredStyle: .Alert)
            
            let cancel = UIAlertAction(title: "OK", style: .Cancel, handler: {(action) -> Void in})
            alert.addAction(cancel)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        // Return the results, cast to an array of Country objects
        return results as! [Country]
    }
    
    // Helper funciton to see if a country has already been saved.
    func countrySaved(countryName: String) -> Bool {
        for country in fetchAllCountries() {
            if countryName == country.countryName {
                countryToPass = country
                return true
            }
        }
        return false
    }
    
}

