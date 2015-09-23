//
//  MapViewController.swift
//  QuandlPractice
//
//  Created by Michael Nichols on 8/25/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        
        // QuandlAPICall()
        
        // Gesture recognizer and assign dropPin method to it
        let longTapAndHoldGesture = UILongPressGestureRecognizer(target: self, action: "dropPin:")
        
        map.addGestureRecognizer(longTapAndHoldGesture)
        
        // Inform the user how to use the map.
        let alert = UIAlertController(title: "Countries of the World", message: "Tap and hold on a country to access data associated with it.", preferredStyle: .Alert)
        
        let cancel = UIAlertAction(title: "OK", style: .Cancel, handler: {(action) -> Void in})
        alert.addAction(cancel)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        navigationController?.navigationBarHidden = true
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBarHidden = false
    }
    
    func reverseLocate(lat: CLLocationDegrees, lon: CLLocationDegrees, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var geocoder = CLGeocoder()
        var manager : CLLocationManager!
        var longitude = lon
        var latitude = lat
        
        var location = CLLocation(latitude: latitude, longitude: longitude) //changed!!!
        
        geocoder.reverseGeocodeLocation(location) {(placemarks, error) -> Void in

            let placeArray = placemarks as? [CLPlacemark]
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            
            // Country
            if let country = placeMark.addressDictionary["Country"] as? NSString {
                completionHandler(result: country, error: nil)
            } else {
                completionHandler(result: "Error", error: NSError(domain: "Location", code: 0, userInfo: [NSLocalizedDescriptionKey: "Location Error"]))
            }
        }
    }
    
    
    // A function to drop a pin on the map if a long tap and hold
    func dropPin(gesture: UIGestureRecognizer) {
        
        if gesture.state == .Began {
            
            // Grabbing coords
            var point = gesture.locationInView(map)
            var locCoord = map.convertPoint(point, toCoordinateFromView: map)
            
            reverseLocate(locCoord.latitude, lon: locCoord.longitude) {result, error in
            
                if let country = result as? String {
                    if Helper.sharedInstance().inDictionary(country, dictionary: WorldBank.COUNTRIES.DATA) {
                        let object = UIApplication.sharedApplication().delegate
                        let appDelegate = object as! AppDelegate
                        appDelegate.country = country
                        var code = WorldBank.COUNTRIES.DATA[country]!["Code"]!
                        appDelegate.code = code
                        self.toPickerView()
                    } else {
                        let alert = UIAlertController(title: country, message: "The tapped item was not a country. Please tap and hold on a country.", preferredStyle: .Alert)
                        
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
    
    // Helper function to push the view to the PhotoAlbumVC
    func toPickerView() {
        
        var controller: TabBarController
        controller = storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! TabBarController
        
        navigationController!.pushViewController(controller, animated: true)
    }
    
}

