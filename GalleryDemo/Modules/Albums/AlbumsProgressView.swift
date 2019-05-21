//
//  ProgressView.swift
//  GalleryDemo
//
//  Created by roman on 19/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

class AlbumsProgressView: UIView {

    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var label: UILabel!

    func showActivityIndicator() {
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
        label.isHidden = true
    }

    func showLabel(text: String) {
        label.isHidden = false
        label.text = text
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
    }
}
