//
//  CoreDataManager.swift
//  CoreDataStack
//
//  Created by Frank Cipolla on 10/1/18.
//  Copyright © 2018 Frank Cipolla. All rights reserved.
//

import Foundation
import CoreData

final public class CoreDataManager {
    /* initially a single managedObjectContext but made it have a child:
    
     By using a private managed object context that operates on a background thread, we can push changes to the persistent store coordinator without blocking the main thread. The changes that are pushed from the child managed object context to the private managed object context won't have a significant impact on the performance or responsiveness of the application because no data is written to disk.
    */
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    // MARK: Stack Setup
    
    // While the managedObjectContext property is marked as public, the setter is private. Only the CoreDataManager instance should be allowed to set the managedObjectContext property.
    
    public private(set) lazy var mainManagedObjectContext: NSManagedObjectContext = {
        // Initialize managed Object Context
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        // configure Managed Object Context
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    }()
    //public private(set) lazy var managedObjectContext: NSManagedObjectContext = {
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        // Initialize managed Object Context
        //let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        // configure Managed Object Context
       // managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator when therre was only one
        managedObjectContext.parent = self.privateManagedObjectContext
        
        return managedObjectContext
    }()
    
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        // fetch Model URL
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension:"momd") else {
            fatalError("Unable to Find Data Model")
        }
        
        // Initialize Managed Object Model
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }
        
        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        // Initialize Persistent Store Coordinator
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        // Helpers
      
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"
        
        // URL Documents Directory
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // URL Persistent Store
       let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        
        // Add Persistent Store
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL, options:options)
        } catch {
            fatalError("Unable to Add Persistent Store")
        }
        
        return persistentStoreCoordinator
        
    }()
    
    // MARK: Saving Changes
    
 /*   public func saveChanges() {
        
        mainManagedObjectContext.performAndWait({
            do {
                if self.mainManagedObjectContext.hasChanges {
                    try self.mainManagedObjectContext.save()
                }
                catch do {
                    // let saveError = err
                    print("Unable to Save Changes of Main Managed Object Context")
                    // print("\(saveError), \(saveError.localizedDescription)")
                }
            }
            } as! () -> Void)
    }
    */
    
}
