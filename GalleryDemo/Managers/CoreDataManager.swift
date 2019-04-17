//
//  CoreDataManager.swift
//  GalleryDemo
//
//  Created by roman on 11/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import CoreData

class CoreDataManager {

    static let shared = CoreDataManager()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Gallery")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }

        return container
    }()

    var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    private init() { }

    func saveContext() {
        guard viewContext.hasChanges else { return }

        do {
            try viewContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
