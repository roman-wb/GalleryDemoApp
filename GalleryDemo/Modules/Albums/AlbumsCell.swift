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

    private var url: URL!

    private var imageLoader: ImageLoader!

    func configure(_ viewModel: AlbumsVMProtocol, with indexPath: IndexPath) {
        guard let album = viewModel.album(at: indexPath.row) else {
            return
        }

        titleLabel.text = album.title

        guard
            let urlString = album.thumb,
            let url = URL(string: urlString) else {
                return
        }

        self.url = url

        imageLoader = ImageLoader(url: url, delegate: self)
        imageLoader.fetch()
    }

    func cancel() {
        guard let imageLoader = imageLoader else {
            return
        }

        imageLoader.cancel()
    }
}

extension AlbumsCell: ImageLoaderDelegate {

    func imageLoaderWillFetch(imageLoader: ImageLoader, url: URL) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.checkURL(url) else {
                return
            }

            self.thumbImageView.image = nil
            self.activityIndicatorView.startAnimating()
        }
    }

    func imageLoaderDidFetch(imageLoader: ImageLoader, url: URL, image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.checkURL(url) else {
                return
            }

            self.thumbImageView.image = image
            self.activityIndicatorView.stopAnimating()
        }
    }

    func imageLoaderDidFetchWithError(imageLoader: ImageLoader, url: URL, error: Error?) {
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self, self.checkURL(url) else {
//                return
//            }
//
//            self.thumbImageView.image = nil
//            self.activityIndicatorView.stopAnimating()
//        }
    }

    private func checkURL(_ url: URL) -> Bool {
        return self.url == url
    }
}
