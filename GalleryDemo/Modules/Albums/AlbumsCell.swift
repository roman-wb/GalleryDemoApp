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

    @IBOutlet private var thumbImageView: WebImageView!
    @IBOutlet private var titleLabel: UILabel!

    private var container: Container!
    private var album: AlbumsResponse.Album!

    func configure(container: Container, album: AlbumsResponse.Album) {
        self.container = container
        self.album = album

        titleLabel.text = album.title
        thumbImageView.setImage(url: album.thumbURL)
    }
}
