//
//  AlbumsCell.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import Swinject

final class PhotosCell: UICollectionViewCell {

    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var thumbImageView: UIImageView!

    private var container: Container!
    private var photo: PhotosResponse.Photo!

    private var thumbURL: URL?
    private var imageLoader: ImageLoaderProtocol?

    func configure(container: Container, photo: PhotosResponse.Photo) {
        self.container = container
        self.photo = photo

        thumbURL = photo.thumbURL

        guard let thumbURL = thumbURL else {
            return
        }

        imageLoader = container.resolve(ImageLoaderProtocol.self)!
        imageLoader?.download(url: thumbURL, delegate: self)
    }

    func didEndDisplaying() {
        imageLoader?.cancel()
    }
}

extension PhotosCell: ImageLoaderDelegate {
    func imageLoaderWillDownloading(imageLoader: ImageLoaderProtocol, url: URL) {
        guard thumbURL == url else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.thumbImageView.image = nil
            self?.activityIndicatorView.startAnimating()
        }
    }

    func imageLoaderDidDownloaded(imageLoader: ImageLoaderProtocol, url: URL, image: UIImage, fromCache: Bool) {
        guard thumbURL == url else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.thumbImageView.image = image
            self?.activityIndicatorView.stopAnimating()
        }
    }

    func imageLoaderDidDownloadedWithError(imageLoader: ImageLoaderProtocol, url: URL) {
        guard thumbURL == url else {
            return
        }

        //
    }
}
