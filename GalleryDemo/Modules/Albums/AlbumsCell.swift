//
//  AlbumsCell.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

final class AlbumsCell: UITableViewCell {

    static let identifier = "AlbumsCell"

    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var thumbImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!

    private var thumbURL: URL!

    private var imageLoader: ImageLoader!

    func configure(_ album: AlbumsResponse.Album) {
        thumbURL = album.thumbURL
        titleLabel.text = album.title

        if thumbURL == nil {
            return
        }

        imageLoader = ImageLoader(url: thumbURL, delegate: self)
        imageLoader.download()
    }

    func cancel() {
        imageLoader.cancel()
    }
}

extension AlbumsCell: ImageLoaderDelegate {

    func imageLoaderWillDownloading(imageLoader: ImageLoader, url: URL) {
        guard self.thumbURL == url else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.thumbImageView.alpha = 0
            self?.thumbImageView.image = nil
            self?.activityIndicatorView.startAnimating()
        }
    }

    func imageLoaderDidDownloaded(imageLoader: ImageLoader, url: URL, image: UIImage) {
        guard self.thumbURL == url else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.thumbImageView.image = image
            self?.thumbImageView.alpha = 0

            UIView.animate(withDuration: 0.25) {
                self?.thumbImageView.alpha = 1
            }
            
            self?.activityIndicatorView.stopAnimating()
        }
    }

    func imageLoaderDidDownloadedWithError(imageLoader: ImageLoader, url: URL) {
        guard self.thumbURL == url else {
            return
        }

        //
    }
}
