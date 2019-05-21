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

    @IBOutlet private var thumbImageView: WebImageView!

    private var container: Container!
    private var photo: PhotosResponse.Photo!

    func configure(container: Container, photo: PhotosResponse.Photo) {
        self.container = container
        self.photo = photo

        thumbImageView.setImage(url: photo.thumbURL)
    }
}
