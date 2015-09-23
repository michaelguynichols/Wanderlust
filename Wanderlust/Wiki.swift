//
//  Wiki.swift
//  QuandlPractice
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
    
    func getWikiData(searchTerms: String,  completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        var url = createQueryURL(baseURL, searchTerms: searchTerms)
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
                if let wikiData = Helper.sharedInstance().parseJSONResult(data) {
                    if let imageInfo = wikiData["query"] as? NSDictionary {
                        if let pages = imageInfo["pages"] as? NSDictionary {
                            // Grabbing the pageid to pull flag photo
                            var pageid = pages.allKeys[0] as! String
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

    func createQueryURL(baseURL: String, searchTerms: String) -> String {
        var searchFormattedForWiki = createWikiAPIURL(searchTerms)
        var mutatedURL = baseURL + "action=query&titles=File:Flag_of_\(searchFormattedForWiki).svg&prop=imageinfo&&iiprop=url&iiurlwidth=220&format=json"
        return mutatedURL
    }
    
    func createWikiURL(country: String) -> String {
        var joinedCountryName = String()
        if country.rangeOfString(" ") != nil {
            for letter in country {
                if letter == " " {
                    joinedCountryName += "_"
                } else {
                    joinedCountryName += String(letter)
                }
            }
        } else {
            joinedCountryName = country
        }
        return Wiki.URLs.WIKI_URL + joinedCountryName
    }
    
    func createWikiAPIURL(country: String) -> String {
        var joinedCountryName = String()
        if country.rangeOfString(" ") != nil {
            for letter in country {
                if letter == " " {
                    joinedCountryName += "%20"
                } else {
                    joinedCountryName += String(letter)
                }
            }
        } else {
            joinedCountryName = country
        }
        return joinedCountryName
    }

    
}