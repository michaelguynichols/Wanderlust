//
//  WorldBank.swift
//  Wanderlust
//
//  Created by Michael Nichols on 8/29/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation

class WorldBank {
    
    var baseURL: String!
    var session: NSURLSession!
    
    init() {
        
        session = NSURLSession.sharedSession()
        baseURL = WorldBank.URLs.BASE_URL
        
    }
    
    class func sharedInstance() -> WorldBank {
        
        struct Singleton {
            static var sharedInstance = WorldBank()
        }
        
        return Singleton.sharedInstance
    }
    
    // Function to get Worldbank data.
    func getWBData(geoCode: String, indicator: String,  completionHandler: (result: (String, String), error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let lowerCaseCode = geoCode.lowercaseString
        
        let url = baseURL + "\(lowerCaseCode)/indicators/\(indicator)" + WorldBank.URLs.REST_URL
        let requestURL = NSURL(string: url)
        
        // Making request
        let request = NSMutableURLRequest(URL: requestURL!)
        
        request.HTTPMethod = "GET"
        
        // Task with request
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                // Handle error
                completionHandler(result: ("Error", "Error"), error: NSError(domain: "Download", code: 0, userInfo: [NSLocalizedDescriptionKey: "Download Error"]))
            } else {
                //let response = NSString(data: data, encoding: NSUTF8StringEncoding)
                if let WBData = Helper.sharedInstance().parseJSONResultWB(data!) {
                    if let dataSet = WBData[1] as? [NSDictionary] {
                        let dataValue = self.grabFirstResult(dataSet)
                        // If data is good, send it to the completion handler.
                        completionHandler(result: dataValue, error: nil)
                    }
                }
            }
        }
        task.resume()
        return task
    }
    
    // Helper function to get the latest data only.
    func grabFirstResult(countryData: [NSDictionary]) -> (String, String) {
        for data in countryData {
            if let dataResult = data["value"] as? String {
                if data["value"] as! String != "<null>" {
                    return (dataResult, data["date"] as! String)
                }
            }
        }
        
        return ("0", "0000")
        
    }
    
}