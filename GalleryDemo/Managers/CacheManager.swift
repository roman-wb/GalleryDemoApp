//
//  CacheManager.swift
//  GalleryDemo
//
//  Created by roman on 03/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import Foundation

final class CacheManager {

    static let shared = CacheManager()

    struct File {
        var date: Date?
        var path: String
    }

    var maxCountOfFiles = 100

    var folder = "cache"

    var document: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }

    var destination: URL {
        return URL(fileURLWithPath: document).appendingPathComponent(folder, isDirectory: true)
    }

    private var fileManager: FileManager {
        return FileManager.default
    }

    private(set) var operation: OperationQueue!

    private init() {
        operation = OperationQueue()
        operation.maxConcurrentOperationCount = 1
    }

    func createDirectory() {
        try? fileManager.createDirectory(atPath: destination.relativePath,
                                         withIntermediateDirectories: true,
                                         attributes: nil)
    }

    func url(forKey key: String) -> URL {
        return destination.appendingPathComponent(key)
    }

    func exists(forKey key: String) -> Bool {
        let path = url(forKey: key).relativePath
        return fileManager.fileExists(atPath: path)
    }

    func write(forKey key: String, data: Data, override: Bool = false) {
        createDirectory()

        if override { remove(forKey: key) }

        try? data.write(to: url(forKey: key), options: [.atomicWrite])
    }

    func writeSync(forKey key: String, data: Data, override: Bool = false) {
        operation.addOperation { [weak self] in
            self?.write(forKey: key, data: data, override: override)
        }
    }

    func read(forKey key: String) -> Data? {
        return try? Data(contentsOf: url(forKey: key))
    }

    func remove(forKey key: String) {
        try? fileManager.removeItem(at: url(forKey: key))
    }

    func removeSync(forKey key: String) {
        operation.addOperation { [weak self] in
            self?.remove(forKey: key)
        }
    }

    func removeAll() {
        try? fileManager.removeItem(at: destination)
    }

    func removeAllSync() {
        operation.addOperation { [weak self] in
            self?.removeAll()
        }
    }

    func cycle() {
        let files = sortedList()

        guard files.count > maxCountOfFiles else { return }

        for file in files[maxCountOfFiles...] {
            try? fileManager.removeItem(atPath: file.path)
        }
    }

    func cycleSync() {
        operation.addOperation { [weak self] in
            self?.cycle()
        }
    }

    func sortedList() -> [File] {
        var files = [File]()

        guard let enumerator = fileManager.enumerator(at: destination,
                                                      includingPropertiesForKeys: nil) else {
            return []
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
