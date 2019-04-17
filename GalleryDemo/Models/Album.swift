//
//  Album.swift
//  GalleryDemo
//
//  Created by roman on 08/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import Foundation

import CoreData

@objc
class Album: NSManagedObject {

    @NSManaged var id: Int
    @NSManaged var title: String
    @NSManaged var thumb: String?

    static func all() -> [Album] {
        let viewContext = CoreDataManager.shared.viewContext
        let fetchRequest = NSFetchRequest<Album>(entityName: "Album")

        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
//            print(#function, error)
            return []
        }
    }

    static func count() -> Int {
        let viewContext = CoreDataManager.shared.viewContext
        let fetchRequest = NSFetchRequest<Album>(entityName: "Album")

        do {
            return try viewContext.count(for: fetchRequest)
        } catch {
//            print(#function, error)
            return 0
        }
    }

    static func create(id: Int, title: String, thumb: String?) {
        let backgroundContext = CoreDataManager.shared.backgroundContext
        let entity = NSEntityDescription.entity(forEntityName: "Album",
                                                in: backgroundContext)

        let album = Album(entity: entity!, insertInto: backgroundContext)
        album.id = id
        album.title = title
        album.thumb = thumb

        if backgroundContext.hasChanges {
            do {
                try backgroundContext.save()
            } catch {
//                print(#function, error)
            }
        }
    }

    static func first(offset: Int = 0) -> Album? {
        let viewContext = CoreDataManager.shared.viewContext
        let fetchRequest = NSFetchRequest<Album>(entityName: "Album")
        fetchRequest.fetchOffset = offset
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]

        do {
            return try viewContext.fetch(fetchRequest).first
        } catch {
//            print(#function, error)
            return nil
        }
    }

    static func deleteAll() {
        let backgroundContext = CoreDataManager.shared.backgroundContext
        let fetchRequest = NSFetchRequest<Album>(entityName: "Album") as? NSFetchRequest<NSFetchRequestResult>
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest!)

        do {
            try backgroundContext.execute(batchDeleteRequest)
        } catch {
//            print(#function, error)
        }
    }
}

extension Album {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)
}
