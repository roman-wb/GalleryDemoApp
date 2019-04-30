//
//  AlbumsCell.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

final class DetailsCell: UICollectionViewCell, UIScrollViewDelegate {
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!

    private var imageURL: URL?
    private var imageLoader: ImageLoader?

    func configure(_ photo: PhotosResponse.Photo) {
        imageURL = photo.imageURL

        if let imageURL = imageURL {
            imageLoader = ImageLoader(url: imageURL, delegate: self)
            imageLoader?.download()
        }
    }

    func setImage(_ image: UIImage) {
        imageView.image = image

        let scale = (frame.width - 20) / image.size.width
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        imageView.frame = CGRect(origin: .zero, size: size)

        updateContentInset()
    }

    func cancel() {
        imageLoader?.cancel()
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateContentInset()
    }

    func updateContentInset() {
        let offsetX = max((scrollView.frame.width - imageView.frame.width) / 2, 0)
        let offsetY = max((scrollView.frame.height - imageView.frame.height) / 2, 0)

        scrollView.alwaysBounceHorizontal = offsetX == 0
        scrollView.alwaysBounceVertical = offsetY == 0

        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}

extension DetailsCell: ImageLoaderDelegate {
    func imageLoaderWillDownloading(imageLoader: ImageLoader, url: URL) {
        guard imageURL == url else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = nil
            self?.activityIndicatorView.startAnimating()
        }
    }

    func imageLoaderDidDownloaded(imageLoader: ImageLoader, url: URL, image: UIImage, fromCache: Bool) {
        guard imageURL == url else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.setImage(image)
            self?.activityIndicatorView.stopAnimating()
        }
    }

    func imageLoaderDidDownloadedWithError(imageLoader: ImageLoader, url: URL) {
        guard imageURL == url else {
            return
        }

        //
    }
}
