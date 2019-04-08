//
//  AlbumsLoadingCell.swift
//  GalleryDemo
//
//  Created by roman on 03/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

class AlbumsLoadingCell: UITableViewCell {

    static let reuseIdentifier = "AlbumsLoadingCell"
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    func configure() {
        activityIndicatorView.startAnimating()
    }
}
