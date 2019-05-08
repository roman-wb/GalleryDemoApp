//
//  AlbumsCell.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import Swinject

final class DetailsCell: UICollectionViewCell {

    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!

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

        var scale: CGFloat!
        if frame.width < frame.height {
            scale = (frame.width - 20) / image.size.width
        } else {
            scale = (frame.height - 20) / image.size.height
        }

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
