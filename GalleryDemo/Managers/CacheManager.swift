//
//  CacheManager.swift
//  GalleryDemo
//
//  Created by roman on 03/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import Foundation

class CacheManager {
    
    struct File {
        var date: Date?
        var path: String
    }
    
    var folder = "cache"
    
    var maxCountOfFiles = 1000
    
    var document: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    
    var destination: URL {
        return URL(fileURLWithPath: document).appendingPathComponent(folder, isDirectory: true)
    }
    
    var fileManager: FileManager {
        return FileManager.default
    }
    
    init() {
        createDirectory()
    }
    
    func createDirectory() {
        if fileManager.fileExists(atPath: destination.relativePath) {
            return
        }
        
        try? fileManager.createDirectory(atPath: destination.relativePath,
                                         withIntermediateDirectories: true,
                                         attributes: nil)
    }
    
    func url(forKey key: String) -> URL {
        return destination.appendingPathComponent(key)
    }
    
    func exists(forKey key: String) -> Bool {
        let url = self.url(forKey: key)
        return fileManager.fileExists(atPath: url.relativePath)
    }
    
    func write(forKey key: String, data: Data, force: Bool = false) {
        createDirectory()
        
        let url = self.url(forKey: key)
        
        if force {
            remove(forKey: key)
        }
        
        try? data.write(to: url, options: [.atomicWrite])
    }
    
    func read(forKey key: String) -> Data? {
        let url = self.url(forKey: key)
        return try? Data(contentsOf: url)
    }
    
    func remove(forKey key: String) {
        let url = self.url(forKey: key)
        try? fileManager.removeItem(at: url)
    }
    
    func removeAll() {
        try? fileManager.removeItem(at: destination)
    }
    
    func cycle() {
        var i = 0
        for file in sortedList() {
            i += 1
            if i > maxCountOfFiles {
                try? fileManager.removeItem(atPath: file.path)
            }
        }
    }
    
    func sortedList() -> [File] {
        var files = [File]()
        
        guard let enumerator = fileManager.enumerator(at: destination,
                                                      includingPropertiesForKeys: nil) else {
            return files
        }
        
        for case let url as URL in enumerator {
            var file = File(date: nil, path: url.relativePath)
            
            if let attributes = try? fileManager.attributesOfItem(atPath: file.path) {
                file.date = attributes[.modificationDate] as? Date
            }
            
            files.append(file)
        }
        
        files.sort {
            guard let date1 = $0.date, let date2 = $1.date else {
                return false
            }
            return date1 > date2
        }
        
        return files
    }
}
