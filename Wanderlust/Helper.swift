//
//  Helper.swift
//  QuandlPractice
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
    
    // Helper function to parse JSON data.
    func parseJSONResult(data: NSData) -> NSDictionary?  {
        var parsingError: NSError? = nil
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as? NSDictionary {
            return parsedResult
        } else {
            let emptyDict = NSDictionary()
            return emptyDict
        }
    }
    
    func inDictionary(country: String, dictionary: NSDictionary) -> Bool {
        var compareKeys = dictionary.allKeys as! [String]
        if contains(compareKeys, country) {
            return true
        } else {
            return false
        }
    }
    
    func formatResult(type: String, result: String) -> String {
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

    func commaDelimit(result: String) -> String {
        var count = 0
        var returnString = String()
        var chopped = chopOffDecimal(result)
        var reversedString = lazy(chopped).reverse()
        
        for num in reversedString {
            count++
            if count % 3 == 0 &&  numLetters(chopped) != count {
                returnString += String(num) + ","
            } else {
                returnString += String(num)
            }
        }
        
        return String(lazy(returnString).reverse())
        
    }
    
    func twoDecFormat(type: String, result: String) -> String {
        if type == "GDP per Capita" {
            var doubleString = (result as NSString).doubleValue
            var str = NSString(format: "%.0f", doubleString)
            return str as String
        } else {
            var doubleString = (result as NSString).doubleValue
            var str = NSString(format: "%.2f", doubleString)
            return str as String
        }
    }
    
    func numLetters(str: String) -> Int {
        var num: Int = 0
        for letter in str {
            num++
        }
        return num
    }
    
    func pullYearFromDate(date: String) -> String {
        var count = 0
        var newDate = String()
        for digit in date {
            if count <= 3 {
                newDate += String(digit)
            }
            count++
        }
        return newDate
    }
    
    func createPinterestSearch(country: String) -> String {
        
        var formattedCountry = String()
        
        for letter in country {
            if letter == " " {
                formattedCountry += "+"
            } else {
                formattedCountry += String(letter)
            }
        }
        
        var URL = "https://www.pinterest.com/search/pins/?q=\(formattedCountry)+food"
        
        return URL
        
    }
    
    func chopOffDecimal(result: String) -> String {
        var final = String()
        for letter in result {
            if letter != "." {
                final += String(letter)
            } else {
                return final
            }
        }
        return final
    }
    
}