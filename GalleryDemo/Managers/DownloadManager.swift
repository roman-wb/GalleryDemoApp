//
//  DownloadManager.swift
//  GalleryDemo
//
//  Created by roman on 05/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import Foundation

//class DownloadManager {
//    
//    typealias LoadingHandler = () -> Void
//    
//    typealias CompletionHandler = (_ data: Data?) -> Void
//    
//    typealias CompletionHandlers = [String: [CompletionHandler]]
//    
//    let cacheManager = CacheManager()
//    
//    private var handlers = CompletionHandlers()
//    
//    private let handlersQueue = DispatchQueue(label: "DownloadManager.handlersQueue")
//    
//    private init() {
//        print("CACHE FOLDER:", cacheManager.destination.relativePath)
//    }
//    
//    func appendHandler(urlString: String, handler: CompletionHandler) {
//        handlersQueue.sync {
//            handlers[urlString]?.append(handler)
//        }
//    }
//    
//    func fetch(_ urlString: String,
//               loadingHandler: @escaping LoadingHandler,
//               completionHandler: @escaping CompletionHandler) {
//        
//        guard handlers[urlString] == nil else {
//            handlers[urlString]?.append(completionHandler)
//            loadingHandler()
//            return
//        }
//        
//        handlers[urlString] = [completionHandler]
//        
//        DispatchQueue.global().async { [weak self] in
//            let cacheKey = "\(urlString.md5).jpg"
//            
//            if let image = self?.image(forKey: cacheKey) {
//                print("CACHED:", urlString)
//                self?.invokeCompletionHandlers(urlString: urlString, image: image)
//                return
//            }
//            
//            loadingHandler()
//            
//            print("DOWNLOADING:", urlString)
//            
//            guard
//                let originalImage = self?.image(forURLString: urlString),
//                let image = self?.resize(forImage: originalImage),
//                let data = image.jpegData(compressionQuality: 1) else {
//                    self?.rejectHandlers(forURLString: urlString)
//                    return
//            }
//            
//            self?.cacheManager.write(forKey: cacheKey, data: data)
//            
//            self?.resolveHandlers(forURLString: urlString, image: image)
//        }
//    }
//    
//    func resolveHandlers(forURLString urlString: String, image: UIImage) {
//        print("RESOLVE:", urlString)
//        DispatchQueue.main.async { [weak self] in
//            guard let handlers = self?.handlers[urlString] else {
//                return
//            }
//            
//            for handler in handlers {
//                handler(urlString, image)
//            }
//            
//            self?.handlers[urlString] = nil
//        }
//    }
//    
//    func rejectHandlers(forURLString urlString: String) {
//        print("REJECT:", urlString)
//        DispatchQueue.main.async { [weak self] in
//            self?.handlers[urlString] = nil
//        }
//    }
//}
