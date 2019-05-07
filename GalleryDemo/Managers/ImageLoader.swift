//
//  AlbumsDownloader.swift
//  GalleryDemo
//
//  Created by roman on 02/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

protocol ImageLoaderProtocol: AnyObject {
    var cache: NSCache<NSString, UIImage>! { get set }

    var url: URL! { get set }

    func download(url: URL, delegate: ImageLoaderDelegate)

    func cancel()
}

protocol ImageLoaderDelegate: AnyObject {
    func imageLoaderWillDownloading(imageLoader: ImageLoaderProtocol, url: URL)

    func imageLoaderDidDownloaded(imageLoader: ImageLoaderProtocol, url: URL, image: UIImage, fromCache: Bool)

    func imageLoaderDidDownloadedWithError(imageLoader: ImageLoaderProtocol, url: URL)
}

final class ImageLoader {

    var cache: NSCache<NSString, UIImage>!

    var url: URL!

    private weak var delegate: ImageLoaderDelegate?

    private var dataTask: URLSessionDataTask?

    private var cacheKey: NSString {
        return url.relativeString as NSString
    }

    private func completionHandler(data: Data?, response: URLResponse?, error: Error?) {
        guard
            error == nil,
            let response = response as? HTTPURLResponse,
            response.statusCode == 200,
            let data = data,
            let image = UIImage(data: data),
            let resizedImage = image.resize(CGSize(width: 800, height: 800)) else {
                delegate?.imageLoaderDidDownloadedWithError(imageLoader: self, url: url)
                return
        }

        cache.setObject(resizedImage, forKey: cacheKey)

        delegate?.imageLoaderDidDownloaded(imageLoader: self, url: url, image: resizedImage, fromCache: false)
    }
}

extension ImageLoader: ImageLoaderProtocol {
    func download(url: URL, delegate: ImageLoaderDelegate) {
        self.url = url
        self.delegate = delegate

        delegate.imageLoaderWillDownloading(imageLoader: self, url: url)

        if let image = cache.object(forKey: cacheKey) {
            delegate.imageLoaderDidDownloaded(imageLoader: self, url: url, image: image, fromCache: true)
            return
        }

        dataTask = URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        dataTask?.resume()
    }

    func cancel() {
        dataTask?.cancel()
    }
}
