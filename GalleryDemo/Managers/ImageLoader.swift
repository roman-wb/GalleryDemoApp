//
//  AlbumsDownloader.swift
//  GalleryDemo
//
//  Created by roman on 02/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

protocol ImageLoaderDelegate: class {
    
    func imageLoaderWillFetch(imageLoader: ImageLoader, url: URL)
    
    func imageLoaderDidFetch(imageLoader: ImageLoader, url: URL, image: UIImage)
}

final class ImageLoader {
    
    private var cacheManager: CacheManager!
    
    var url: URL!
    
    weak var delegate: ImageLoaderDelegate?
    
    var resize: CGSize?

    private var downloadTask: URLSessionDownloadTask?
    
    var cacheKey: String {
        return url.lastPathComponent.md5.appending(".jpg")
    }
    
    var downloadKey: String {
        return cacheKey.appending(".tmp")
    }
    
    init(resize: CGSize?, delegate: ImageLoaderDelegate?) {
        self.resize = resize
        self.delegate = delegate
        
        cacheManager = CacheManager()
    }
    
    func cancel() {
        downloadTask?.cancel { [weak self] (data) in
            guard let self = self, let data = data else { return }
            
            self.cacheManager.write(forKey: self.downloadKey, data: data, force: true)
        }
    }
    
    func fetch(_ url: URL) {
        self.url = url
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            if let data = self.cacheManager.read(forKey: self.cacheKey),
                let image = UIImage(data: data) {
                // print("CACHED:", self.url.absoluteURL)
                self.delegate?.imageLoaderDidFetch(imageLoader: self, url: self.url, image: image)
                return
            }
            
            self.delegate?.imageLoaderWillFetch(imageLoader: self, url: self.url)
            
            if let resumeData = self.cacheManager.read(forKey: self.downloadKey) {
                // print("RESUME:", self.url.absoluteURL)
                self.downloadTask = URLSession.shared.downloadTask(withResumeData: resumeData,
                                                                   completionHandler: self.completionHandler)
            } else {
                // print("DOWNLOADING:", self.url.absoluteURL)
                self.downloadTask = URLSession.shared.downloadTask(with: self.url,
                                                                   completionHandler: self.completionHandler)
            }
            
            self.downloadTask?.resume()
        }
    }
    
    private func completionHandler(localURL: URL?, response: URLResponse?, error: Error?) {
        guard
            error == nil,
            let localURL = localURL,
            let originalData = try? Data(contentsOf: localURL),
            let originalImage = UIImage(data: originalData),
            let resizedImage = resize(image: originalImage),
            let resizedData = resizedImage.jpegData(compressionQuality: 1) else {
                return
        }
        
        store(data: resizedData)
        cycle()
        
        delegate?.imageLoaderDidFetch(imageLoader: self, url: self.url, image: resizedImage)
    }
    
    private func store(data: Data) {
        cacheManager.remove(forKey: downloadKey)
        cacheManager.write(forKey: cacheKey, data: data, force: true)
    }
    
    private func cycle() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.cacheManager.cycle()
        }
    }
    
    private func resize(image: UIImage) -> UIImage? {
        guard let resize = resize else {
            return image
        }
        
        let size = image.size
        
        let widthRatio = resize.width / size.width
        let heightRatio = resize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
