//
//  Wiki.swift
//  Wanderlust
//
//  Created by Michael Nichols on 8/27/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation
import UIKit

class Wiki {
    
    var baseURL: String!
    var session: NSURLSession!
    
    init() {
        
        session = NSURLSession.sharedSession()
        baseURL = Wiki.URLs.BASE_URL
        
    }
    
    class func sharedInstance() -> Wiki {
        
        struct Singleton {
            static var sharedInstance = Wiki()
        }
        
        return Singleton.sharedInstance
    }
    
    // Getting Wikipedia data to pull the flag image.
    func getWikiData(searchTerms: String,  completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let url = createQueryURL(baseURL, searchTerms: searchTerms)
        let requestURL = NSURL(string: url)
        
        // Making request
        let request = NSMutableURLRequest(URL: requestURL!)
        
        request.HTTPMethod = "GET"
        
        // Task with request
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                // Handle error
                completionHandler(result: nil, error: NSError(domain: "Download", code: 0, userInfo: [NSLocalizedDescriptionKey: "Download Error"]))
            } else {
                if let wikiData = Helper.sharedInstance().parseJSONResultWiki(data!) {
                    if let imageInfo = wikiData["query"] as? NSDictionary {
                        if let pages = imageInfo["pages"] as? NSDictionary {
                            // Grabbing the pageid to pull flag photo
                            let pageid = pages.allKeys[0] as! String
                            if let negativeOne = pages[pageid] as? NSDictionary {
                                if let imageInfo = negativeOne["imageinfo"] as? [NSDictionary] {
                                    for dict in imageInfo {
                                        if let thumbURL = dict["thumburl"] as? String {
                                            let imageURL = NSData(contentsOfURL: NSURL(string: thumbURL)!)
                                            let image = UIImage(data: imageURL!)
                                            completionHandler(result: image, error: nil)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        task.resume()
        return task
    }

    // Helper function to create Wikipedia search url.
    func createQueryURL(baseURL: String, searchTerms: String) -> String {
        let searchFormattedForWiki = createWikiAPIURL(searchTerms)
        let mutatedURL = baseURL + "action=query&titles=File:Flag_of_\(searchFormattedForWiki).svg&prop=imageinfo&&iiprop=url&iiurlwidth=220&format=json"
        return mutatedURL
    }
    
    // Creating the search URL for Wikipedia button press.
    func createWikiURL(country: String) -> String {
        var joinedCountryName = String()
        if country.rangeOfString(" ") != nil {
            for letter in country.characters {
                if letter == " " {
                    joinedCountryName += "_"
                } else {
                    joinedCountryName += String(letter)
                }
            }
        } else {
            joinedCountryName = country
        }
        
        // A few countries had exceptions as names.

        if country == "Saint Barthélemy" {
            joinedCountryName = "Saint_Barthelemy"
        }
        
        return Wiki.URLs.WIKI_URL + joinedCountryName
    
    }
    
    
    func createWikiAPIURL(country: String) -> String {
        var joinedCountryName = String()
        if country.rangeOfString(" ") != nil {
            for letter in country.characters {
                if letter == " " {
                    joinedCountryName += "%20"
                } else {
                    joinedCountryName += String(letter)
                }
            }
        } else {
            joinedCountryName = country
        }
        
        // A few countries had exceptions as names.
        if country == "Myanmar (Burma)" {
            joinedCountryName = "Myanmar"
        } else if country == "Macedonia (FYROM)" {
            joinedCountryName = "Macedonia"
        } else if country == "The Netherlands" {
            joinedCountryName = "Netherlands"
        } else if country == "Falkland Islands (Islas Malvinas)" {
            joinedCountryName = "Falkland%20Islands"
        } else if country == "Saint Barthélemy" {
            joinedCountryName = "Saint%20Barthelemy"
        } else if country == "Reunion" {
            joinedCountryName = "France"
        } else if country == "Pitcairn" {
            joinedCountryName = "Pitcairn%20Islands"
        } else if country == "Saint Pierre and Miquelon" {
            joinedCountryName = "Saint-Pierre%20and%20Miquelon"
        }
        
        return joinedCountryName
    }

    struct Caches {
        static let imageCache = ImageCache()
    }
    
}