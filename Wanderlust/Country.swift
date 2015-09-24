//
//  Country.swift
//  Wanderlust
//
//  Created by Michael Nichols on 9/4/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Country)

class Country: NSManagedObject {
    
    @NSManaged var countryName: String
    var countryData = [String: (String, String)]()
    @NSManaged var countryCode: String
    @NSManaged var population: String?
    @NSManaged var populationDate: String
    @NSManaged var ruralPopulation: String
    @NSManaged var ruralPopulationDate: String
    @NSManaged var urbanPopulation: String
    @NSManaged var urbanPopulationDate: String
    @NSManaged var populationGrowth: String
    @NSManaged var populationGrowthDate: String
    @NSManaged var lifeExpectancy: String
    @NSManaged var lifeExpectancyDate: String
    @NSManaged var laborForce: String
    @NSManaged var laborForceDate: String
    @NSManaged var unemploymentRate: String
    @NSManaged var unemploymentRateDate: String
    @NSManaged var gdpTotal: String
    @NSManaged var gdpTotalDate: String
    @NSManaged var gdpPerCapita: String
    @NSManaged var gdpPerCapitaDate: String
    @NSManaged var gdpAnnualGrowth: String
    @NSManaged var gdpAnnualGrowthDate: String
    @NSManaged var inflation: String
    @NSManaged var inflationDate: String
    @NSManaged var marketCapitalization: String
    @NSManaged var marketCapitalizationDate: String
    @NSManaged var lendingRate: String
    @NSManaged var lendingRateDate: String
    @NSManaged var taxRate: String
    @NSManaged var taxRateDate: String
    @NSManaged var forestArea: String
    @NSManaged var forestAreaDate: String
    @NSManaged var co2: String
    @NSManaged var co2Date: String
    @NSManaged var rd: String
    @NSManaged var rdDate: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(name: String, context: NSManagedObjectContext) {
        
        // Core data
        let entity = NSEntityDescription.entityForName("Country", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        countryName = name
        countryCode = WorldBank.COUNTRIES.DATA[countryName]!["Code"]!
        
    }
    
    var flagImage: UIImage? {
        // getter and setter to handle putting new images in the cache and calling those already in it
        get {
            return Wiki.Caches.imageCache.imageWithIdentifier(countryName)
        }
        
        set {
            Wiki.Caches.imageCache.storeImage(newValue, withIdentifier: countryName)
        }
    }
    
    // Helper function to add data to the country based on the chosen indicator
    func addToCountryData(indicator: String, result: (String, String)) {
        switch (indicator) {
            case "Population":
                population = result.0
                populationDate = result.1
                countryData["Population"] = (population!, populationDate)
            case "Urban Population":
                urbanPopulation = result.0
                urbanPopulationDate = result.1
                countryData["Urban Population"] = (urbanPopulation, urbanPopulationDate)
            case "Rural Population":
                ruralPopulation = result.0
                ruralPopulationDate = result.1
                countryData["Rural Population"] = (ruralPopulation, ruralPopulationDate)
            case "Population Growth":
                populationGrowth = result.0
                populationGrowthDate = result.1
                countryData["Population Growth"] = (populationGrowth, populationGrowthDate)
            case "Life Expectancy":
                lifeExpectancy = result.0
                lifeExpectancyDate = result.1
                countryData["Life Expectancy"] = (lifeExpectancy, lifeExpectancyDate)
            case "Labor Force":
                laborForce = result.0
                laborForceDate = result.1
                countryData["Labor Force"] = (laborForce, laborForceDate)
            case "Unemployment Rate":
                unemploymentRate = result.0
                unemploymentRateDate = result.1
                countryData["Unemployment Rate"] = (unemploymentRate, unemploymentRateDate)
            case "GDP Total":
                gdpTotal = result.0
                gdpTotalDate = result.1
                countryData["GDP Total"] = (gdpTotal, gdpTotalDate)
            case "GDP per Capita":
                gdpPerCapita = result.0
                gdpPerCapitaDate = result.1
                countryData["GDP per Capita"] = (gdpPerCapita, gdpPerCapitaDate)
            case "GDP Annual Growth":
                gdpAnnualGrowth = result.0
                gdpAnnualGrowthDate = result.1
                countryData["GDP Annual Growth"] = (gdpAnnualGrowth, gdpAnnualGrowthDate)
            case "Inflation":
                inflation = result.0
                inflationDate = result.1
                countryData["Inflation"] = (inflation, inflationDate)
            case "Market Capitalization":
                marketCapitalization = result.0
                marketCapitalizationDate = result.1
                countryData["Market Capitalization"] = (marketCapitalization, marketCapitalizationDate)
            case "Lending Rate":
                lendingRate = result.0
                lendingRateDate = result.1
                countryData["Lending Rate"] = (lendingRate, lendingRateDate)
            case "Tax Rate (% of GDP)":
                taxRate = result.0
                taxRateDate = result.1
                countryData["Tax Rate (% of GDP)"] = (taxRate, taxRateDate)
            case "Forest Area":
                forestArea = result.0
                forestAreaDate = result.1
                countryData["Forest Area"] = (forestArea, forestAreaDate)
            case "CO2 Emissions":
                co2 = result.0
                co2Date = result.1
                countryData["CO2 Emissions"] = (co2, co2Date)
            case "R&D (% of GDP)":
                rd = result.0
                rdDate = result.1
                countryData["R&D (% of GDP)"] = (rd, rdDate)
        default:
            return
        }
    }
    
    // Helper function to build all of the country's data if available.
    func buildCountryData() {
        countryData["Population"] = (population!, populationDate)
        countryData["Urban Population"] = (urbanPopulation, urbanPopulationDate)
        countryData["Rural Population"] = (ruralPopulation, ruralPopulationDate)
        countryData["Population Growth"] = (populationGrowth, populationGrowthDate)
        countryData["Life Expectancy"] = (lifeExpectancy, lifeExpectancyDate)
        countryData["Labor Force"] = (laborForce, laborForceDate)
        countryData["Unemployment Rate"] = (unemploymentRate, unemploymentRateDate)
        countryData["GDP Total"] = (gdpTotal, gdpTotalDate)
        countryData["GDP per Capita"] = (gdpPerCapita, gdpPerCapitaDate)
        countryData["GDP Annual Growth"] = (gdpAnnualGrowth, gdpAnnualGrowthDate)
        countryData["Inflation"] = (inflation, inflationDate)
        countryData["Market Capitalization"] = (marketCapitalization, marketCapitalizationDate)
        countryData["Lending Rate"] = (lendingRate, lendingRateDate)
        countryData["Tax Rate (% of GDP)"] = (taxRate, taxRateDate)
        countryData["Forest Area"] = (forestArea, forestAreaDate)
        countryData["CO2 Emissions"] = (co2, co2Date)
        countryData["R&D (% of GDP)"] = (rd, rdDate)
    }
    
    // Helper function to empty old data upon data refresh.
    func rebuildCountryData() {
        countryData["Population"] = ("", "")
        countryData["Urban Population"] = ("", "")
        countryData["Rural Population"] = ("", "")
        countryData["Population Growth"] = ("", "")
        countryData["Life Expectancy"] = ("", "")
        countryData["Labor Force"] = ("", "")
        countryData["Unemployment Rate"] = ("", "")
        countryData["GDP Total"] = ("", "")
        countryData["GDP per Capita"] = ("", "")
        countryData["GDP Annual Growth"] = ("", "")
        countryData["Inflation"] = ("", "")
        countryData["Market Capitalization"] = ("", "")
        countryData["Lending Rate"] = ("", "")
        countryData["Tax Rate (% of GDP)"] = ("", "")
        countryData["Forest Area"] = ("", "")
        countryData["CO2 Emissions"] = ("", "")
        countryData["R&D (% of GDP)"] = ("", "")
        
        buildCountryData()
    }

    
}