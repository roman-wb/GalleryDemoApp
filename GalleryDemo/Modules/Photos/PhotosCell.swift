//
//  AlbumsCell.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

final class PhotosCell: UICollectionViewCell {
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var thumbImageView: UIImageView!

    private var thumbURL: URL?

    private var imageLoader: ImageLoader?

    func configure(_ photo: PhotosResponse.Photo) {
        thumbURL = photo.thumbURL

        if let thumbURL = thumbURL {
            imageLoader = ImageLoader(url: thumbURL, delegate: self)
            imageLoader?.download()
        }
    }

    func didEndDisplaying() {
        imageLoader?.cancel()
    }
}

extension PhotosCell: ImageLoaderDelegate {
    func imageLoaderWillDownloading(imageLoader: ImageLoader, url: URL) {
        guard thumbURL == url else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.thumbImageView.image = nil
            self?.activityIndicatorView.startAnimating()
        }
    }

    func imageLoaderDidDownloaded(imageLoader: ImageLoader, url: URL, image: UIImage, fromCache: Bool) {
        guard thumbURL == url else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.thumbImageView.image = image
            self?.activityIndicatorView.stopAnimating()
        }
    }

    func imageLoaderDidDownloadedWithError(imageLoader: ImageLoader, url: URL) {
        guard thumbURL == url else {
            return
        }

        //
    }
}
