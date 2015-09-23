//
//  Helper.swift
//  Wanderlust
//
//  Created by Michael Nichols on 8/27/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation

class Helper {
    
    class func sharedInstance() -> Helper {
        
        struct Singleton {
            static var sharedInstance = Helper()
        }
        
        return Singleton.sharedInstance
    }
    
    // Helper function to parse JSON data from Wikipedia.
    func parseJSONResultWiki(data: NSData) -> NSDictionary?  {
        let parsedResult: NSDictionary?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
            return parsedResult
        } catch _ {
            let emptyDict = NSDictionary()
            return emptyDict
        }
    }
    
    // Helper function to parse JSON data from Worldbank.
    func parseJSONResultWB(data: NSData) -> NSArray?  {
        let parsedResult: NSArray?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? NSArray
            return parsedResult
        } catch _ {
            let emptyDict = NSArray()
            return emptyDict
        }
    }
    
    // Helper function to determine whether a country is in the dictionary
    func inDictionary(country: String, dictionary: NSDictionary) -> Bool {
        let compareKeys = dictionary.allKeys as! [String]
        if compareKeys.contains(country) {
            return true
        } else {
            return false
        }
    }
    
    // Helper function to format data results.
    func formatResult(type: String, result: String) -> String? {
        switch (type) {
            case "GDP per Capita":
                return "$" + commaDelimit(twoDecFormat(type, result: result))
            case "Tax Rate (% of GDP)":
                return twoDecFormat(type, result: result) + "%"
            case "Population":
                return commaDelimit(result)
            case "Urban Population":
                return commaDelimit(result)
            case "Rural Population":
                return commaDelimit(result)
            case "Population Growth":
                return twoDecFormat(type, result: result) + "%"
            case "Unemployment Rate":
                return twoDecFormat(type, result: result) + "%"
            case "GDP Annual Growth":
                return twoDecFormat(type, result: result) + "%"
            case "CO2 Emissions":
                return twoDecFormat(type, result: result) + " metric tons per capita"
            case "Forest Area":
                return twoDecFormat(type, result: result) + "%"
            case "Inflation":
                return twoDecFormat(type, result: result) + "%"
            case "GDP Total":
                return "$" + commaDelimit(result)
            case "R&D (% of GDP)":
                return twoDecFormat(type, result: result) + "%"
            case "Labor Force":
                return commaDelimit(result)
            case "Market Capitalization":
                return "$" + commaDelimit(result)
            case "Lending Rate":
                return twoDecFormat(type, result: result) + "%"
            case "Life Expectancy":
                return commaDelimit(result)
        default:
            return "Error"
            
        }
    }

    // Helper function to add proper commas to data.
    func commaDelimit(result: String) -> String {
        var count = 0
        var returnString = String()
        let chopped = chopOffDecimal(result)
        let reversedString = chopped.characters.reverse()
        
        for num in reversedString {
            count++
            if count % 3 == 0 &&  numLetters(chopped) != count {
                returnString += String(num) + ","
            } else {
                returnString += String(num)
            }
        }
        
        return String(returnString.characters.reverse())
        
    }
    
    // Formatting data with decimals.
    func twoDecFormat(type: String, result: String) -> String {
        if type == "GDP per Capita" {
            let doubleString = (result as NSString).doubleValue
            let str = NSString(format: "%.0f", doubleString)
            return str as String
        } else {
            let doubleString = (result as NSString).doubleValue
            let str = NSString(format: "%.2f", doubleString)
            return str as String
        }
    }
    
    // Grabbing number of letters in string.
    func numLetters(str: String) -> Int {
        return str.characters.count
    }
    
    // Grabbing the year in a date.
    func pullYearFromDate(date: String) -> String {
        var count = 0
        var newDate = String()
        for digit in date.characters {
            if count <= 3 {
                newDate += String(digit)
            }
            count++
        }
        return newDate
    }
    
    // Getting rid of decimals when unnecessary.
    func chopOffDecimal(result: String) -> String {
        var final = String()
        for letter in result.characters {
            if letter != "." {
                final += String(letter)
            } else {
                return final
            }
        }
        return final
    }
    
}