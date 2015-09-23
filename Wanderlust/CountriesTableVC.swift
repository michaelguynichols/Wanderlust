//
//  CountriesTableVC.swift
//  Wanderlust
//
//  Created by Michael Nichols on 9/11/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class CountriesTableVC: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var country: Country!
    var cache = ImageCache.Caches.imageCache
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Creating edit button
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        do {
            // Performing the fetch
            try fetchedResultsController.performFetch()
        } catch _ {
            // Alert if error
            let alert = UIAlertController(title: "Fetch Error", message: "The data fetch failed.", preferredStyle: .Alert)
            
            let cancel = UIAlertAction(title: "OK", style: .Cancel, handler: {(action) -> Void in})
            alert.addAction(cancel)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        // Set the delegate to this view controller
        fetchedResultsController.delegate = self
        
        // Changing the separator color
        tableView.separatorColor = UIColor.init(red: 59/256, green: 139/256, blue: 148/256, alpha: 1.0)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // Hiding the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // Core Data Convenience functions
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStack.sharedInstance().managedObjectContext!
        }()
    
    func saveContext() {
        CoreDataStack.sharedInstance().saveContext()
    }
    
    
    // Lazy fetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchedRequest = NSFetchRequest(entityName: "Country")
        fetchedRequest.sortDescriptors = [NSSortDescriptor(key: "countryName", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    
    // Table view methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] 
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let country = fetchedResultsController.objectAtIndexPath(indexPath) as! Country
        
        let CellIdentifier = "CountryCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)!
        
        // Setting flag image and labels
        cell.imageView?.image = country.flagImage
        cell.textLabel!.text = country.countryName
                
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (editingStyle) {
        case .Delete:
            let country = fetchedResultsController.objectAtIndexPath(indexPath) as! Country
            deleteCountry(country)
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let country = fetchedResultsController.objectAtIndexPath(indexPath) as! Country
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.pickedCountry = country
        toPickerView()
        
    }
    
    // Helper function to delete a country from the context.
    func deleteCountry(country: Country) {
        cache.deletePhotoCache(country)
        sharedContext.deleteObject(country)
        saveContext()
    }
    
    
    // The delegate methods for fetched results controller
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            _ = tableView.cellForRowAtIndexPath(indexPath!)
            _ = controller.objectAtIndexPath(indexPath!) as! Country
        default:
            return
        }
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    // Helper function to push the view to the DataPickerController
    func toPickerView() {
        
        self.performSegueWithIdentifier("fromTableToDataVC", sender: self)
    }
    
}































