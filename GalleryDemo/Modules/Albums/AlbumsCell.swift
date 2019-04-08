//
//  AlbumsCell.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

final class AlbumsCell: UITableViewCell {
    
    static let reuseIdentifier = "AlbumsCell"
    
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var thumbImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    
    private var url: URL!
    
    private var imageLoader: ImageLoader!
    
    private let resize = CGSize(width: 800, height: 800)
    
    func configure(_ album: Album) {
        titleLabel.text = album.title
        
        guard let urlString = album.thumb,
            let url = URL(string: urlString) else {
                return
        }
        
        self.url = url
        
        imageLoader = ImageLoader(resize: resize, delegate: self)
        imageLoader.fetch(url)
    }
    
    func cancel() {
        imageLoader.cancel()
    }
}

extension AlbumsCell: ImageLoaderDelegate {
    func imageLoaderWillFetch(imageLoader: ImageLoader, url: URL) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.url == url else { return }
            
            self.thumbImageView.image = nil
            self.activityIndicatorView.startAnimating()
        }
    }
    
    func imageLoaderDidFetch(imageLoader: ImageLoader, url: URL, image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.url == url else { return }
            
            self.thumbImageView.image = image
            self.activityIndicatorView.stopAnimating()
        }
    }
}
