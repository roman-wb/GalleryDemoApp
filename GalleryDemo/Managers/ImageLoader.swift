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

    weak var delegate: ImageLoaderDelegate?

    var url: URL

    private var downloadTask: URLSessionDownloadTask?

    private lazy var cache: URLCache = {
        return URLCache(memoryCapacity: 0, diskCapacity: 100 * 1024 * 1024, diskPath: "ImageLoader.Cache")
    }()

    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = urlCache
        return URLSession(configuration: config)
    }()

    init(url: URL, delegate: ImageLoaderDelegate?) {
        self.url = url
        self.delegate = delegate
    }

    func download() {
        delegate?.imageLoaderWillDownloading(imageLoader: self, url: url)

        downloadTask = urlSession.downloadTask(with: url, completionHandler: completionHandler)
        downloadTask?.resume()
    }

    func cancel() {
        downloadTask?.cancel()
    }

    private func completionHandler(localURL: URL?, response: URLResponse?, error: Error?) {
        guard
            error == nil,
            let localURL = localURL,
            let response = response,
            let originalData = try? Data(contentsOf: localURL),
            let originalImage = UIImage(data: originalData),
            let resizedImage = originalImage.resize(CGSize(width: 800, height: 800)),
            let resizedData = resizedImage.jpegData(compressionQuality: 1) else {
                delegate?.imageLoaderDidDownloadedWithError(imageLoader: self, url: url)
                return
        }

        let cachedResponse = CachedURLResponse(response: response, data: resizedData)
        if let urlRequest = downloadTask?.currentRequest {
            urlCache.storeCachedResponse(cachedResponse, for: urlRequest)
        }

        delegate?.imageLoaderDidDownloaded(imageLoader: self, url: url, image: resizedImage)
    }
}
