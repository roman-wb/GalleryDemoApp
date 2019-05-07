//
//  AlbumsCell.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import Swinject

final class AlbumsCell: UITableViewCell {

    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var thumbImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!

    private var container: Container!
    private var album: AlbumsResponse.Album!

    private var thumbURL: URL?
    private var imageLoader: ImageLoaderProtocol?

    func configure(container: Container, album: AlbumsResponse.Album) {
        self.container = container
        self.album = album

        thumbURL = album.thumbURL
        titleLabel.text = album.title

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

extension AlbumsCell: ImageLoaderDelegate {
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
