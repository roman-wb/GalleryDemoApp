//
//  PersistentContainer.swift
//  GalleryDemo
//
//  Created by roman on 09/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import CoreData

class PersistentContainer: NSPersistentContainer {

    func saveContext(backgroundContext: NSManagedObjectContext? = nil) {
        let context = backgroundContext ?? viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch let error as NSError {
            print("Error: \(error), \(error.userInfo)")
        }
    }
}
