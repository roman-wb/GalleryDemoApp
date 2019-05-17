//
//  AlbumsCell.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import Swinject

class WebImageView: UIImageView {

    private var url: URL!
    private var cache: NSCache<NSString, UIImage>!
    private var dataTask: URLSessionDataTask?

    private var cacheKey: NSString {
        return url.relativeString as NSString
    }

    func setImage(url: URL) {
        self.url = url

        dataTask?.cancel()

        if let image = cache.object(forKey: cacheKey) {
            self.image = image
            return
        }

        dataTask = URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        dataTask?.resume()
    }

    private func completionHandler(data: Data?, response: URLResponse?, error: Error?) {
        guard
            error == nil,
            let data = data,
            let image = UIImage(data: data),
            let resizedImage = image.resize(CGSize(width: 800, height: 800)) else {
                return
        }

        self.image = resizedImage

        cache.setObject(resizedImage, forKey: cacheKey)
    }
}

final class DetailsCell: UICollectionViewCell {

    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: WebImageView!

    private var container: Container!
    private var photo: PhotosResponse.Photo!

    private var imageURL: URL?
    private var imageLoader: ImageLoaderProtocol?

    func configure(container: Container, photo: PhotosResponse.Photo) {
        self.container = container
        self.photo = photo

        imageURL = photo.imageURL

        guard let imageURL = imageURL else {
            return
        }

        imageLoader = container.resolve(ImageLoaderProtocol.self)!
        imageLoader?.download(url: imageURL, delegate: self)
    }

    func setImage(_ image: UIImage) {
        imageView.image = image

        updateZoom()
        updateInsets()
    }

    func didEndDisplaying() {
        imageLoader?.cancel()
    }

    func updateZoom() {
        scrollView.zoomScale = 1.0

        guard let image = imageView.image else { return }

        let widthRatio = (frame.width - 20) / image.size.width
        let heightRatio = (frame.height - 20) / image.size.height
        let scale = min(widthRatio, heightRatio)
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        imageView.frame = CGRect(origin: .zero, size: size)
        scrollView.contentSize = size
    }

    func updateInsets() {
        let offsetX = max((scrollView.frame.width - imageView.frame.width) / 2, 0)
        let offsetY = max((scrollView.frame.height - imageView.frame.height) / 2, 0)

        scrollView.alwaysBounceHorizontal = offsetX == 0
        scrollView.alwaysBounceVertical = offsetY == 0

        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}

extension DetailsCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateInsets()
    }
}

extension DetailsCell: ImageLoaderDelegate {
    func imageLoaderWillDownloading(imageLoader: ImageLoaderProtocol, url: URL) {
        guard imageURL == url else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = nil
            self?.activityIndicatorView.startAnimating()
        }
    }

    func imageLoaderDidDownloaded(imageLoader: ImageLoaderProtocol, url: URL, image: UIImage, fromCache: Bool) {
        guard imageURL == url else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.setImage(image)
            self?.activityIndicatorView.stopAnimating()
        }
    }

    func imageLoaderDidDownloadedWithError(imageLoader: ImageLoaderProtocol, url: URL) {
        guard imageURL == url else {
            return
        }

        //
    }
}
