//
//  CoreDataManager.swift
//  CoreDataStack
//
//  Created by Frank Cipolla on 1/17/19.
//  Copyright © 2019 Frank Cipolla. All rights reserved.
//

import CoreData

final class CoreDataManager {   // not intended to be subclassed
    
    // MARK: - Properties
    
    private let modelName: String   // only parameter passed in
    
    
    // MARK: - Initialization
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    // MARK: - Instantiate Core Data Stack
    
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {  // Only make the setter private. Set within this closure
        // Initialize Managed Object Context
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        // Configure Managed Object Context
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = { // Set within this closure
        /*
         If the data model isn't present in the application bundle or the application is unable to load the data model from the application bundle, we throw a fatal error. This should NEVER happen in production.
         */
        
        // Fetch Model URL
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else { // This is the compiled version of the data model.
            fatalError("Unable to find Data Model")
        }
        // Initialize the Managed Object Model
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
        
        do {
            // try to Add Persistent Store
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL, options: nil)
        } catch {
            fatalError("Unable to Add Persistent Store")
        }
        return persistentStoreCoordinator
    } ()
    
    
}
