//
//  AlbumsDownloader.swift
//  GalleryDemo
//
//  Created by roman on 02/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

protocol ImageLoaderDelegate: class {

    func imageLoaderWillDownloading(imageLoader: ImageLoader, url: URL)

    func imageLoaderDidDownloaded(imageLoader: ImageLoader, url: URL, image: UIImage)

    func imageLoaderDidDownloadedWithError(imageLoader: ImageLoader, url: URL)
}

final class ImageLoader {

    var url: URL

    weak var delegate: ImageLoaderDelegate?

    private var dataTask: URLSessionDataTask?

    static var cache = NSCache<NSString, UIImage>()

    private var cacheKey: NSString {
        return url.relativeString as NSString
    }

    init(url: URL, delegate: ImageLoaderDelegate?) {
        self.url = url
        self.delegate = delegate
    }

    func download() {
        delegate?.imageLoaderWillDownloading(imageLoader: self, url: url)

        if let image = ImageLoader.cache.object(forKey: cacheKey) {
            delegate?.imageLoaderDidDownloaded(imageLoader: self, url: url, image: image)
            return
        }

        dataTask = URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        dataTask?.resume()
    }

    func cancel() {
        dataTask?.cancel()
    }

    private func completionHandler(data: Data?, response: URLResponse?, error: Error?) {
        guard
            error == nil,
//            let response = response as? HTTPURLResponse,
//            response.statusCode == 200,
            let data = data,
            let image = UIImage(data: data),
            let resizedImage = image.resize(CGSize(width: 800, height: 800)) else {
                delegate?.imageLoaderDidDownloadedWithError(imageLoader: self, url: url)
                return
        }

        ImageLoader.cache.setObject(resizedImage, forKey: cacheKey)

        delegate?.imageLoaderDidDownloaded(imageLoader: self, url: url, image: resizedImage)
    }
}
