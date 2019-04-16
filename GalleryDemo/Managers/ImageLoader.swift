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

    func imageLoaderDidFetchWithError(imageLoader: ImageLoader, url: URL, error: Error?)
}

final class ImageLoader {

    let resize = CGSize(width: 800, height: 800)

    var url: URL

    weak var delegate: ImageLoaderDelegate?

    var cacheManager: CacheManager {
        return CacheManager.shared
    }

    private var downloadTask: URLSessionDownloadTask?

    var cacheKey: String {
        return url.lastPathComponent.md5.appending(".jpg")
    }

    var downloadKey: String {
        return cacheKey.appending(".tmp")
    }

    init(url: URL, delegate: ImageLoaderDelegate?) {
        self.url = url
        self.delegate = delegate
    }

    func cancel() {
        downloadTask?.cancel { [weak self] (data) in
            guard let self = self, let data = data else { return }

            self.cacheManager.writeSync(forKey: self.downloadKey, data: data, override: true)
        }
    }

    func fetch() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            if
                let data = self.cacheManager.read(forKey: self.cacheKey),
                let image = UIImage(data: data)
            {
//                print("CACHED:", self.url.absoluteURL)
                self.delegate?.imageLoaderDidFetch(imageLoader: self,
                                                   url: self.url,
                                                   image: image)
                return
            }

            self.delegate?.imageLoaderWillFetch(imageLoader: self, url: self.url)

            if let resumeData = self.cacheManager.read(forKey: self.downloadKey) {
//                print("RESUME:", self.url.absoluteURL)
                self.downloadTask = URLSession.shared.downloadTask(withResumeData: resumeData,
                                                                   completionHandler: self.completionHandler)
            } else {
//                print("DOWNLOADING:", self.url.absoluteURL)
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
                delegate?.imageLoaderDidFetchWithError(imageLoader: self, url: self.url, error: error)
                return
        }

        cacheManager.removeSync(forKey: downloadKey)
        cacheManager.writeSync(forKey: cacheKey, data: resizedData, override: true)

        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.cacheManager.cycleSync()
        }

        delegate?.imageLoaderDidFetch(imageLoader: self, url: self.url, image: resizedImage)
    }

    private func resize(image: UIImage) -> UIImage? {
        let size = image.size

        let widthRatio = resize.width / size.width
        let heightRatio = resize.height / size.height

        var newSize: CGSize
        if widthRatio > heightRatio {
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
