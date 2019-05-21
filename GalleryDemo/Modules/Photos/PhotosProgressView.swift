//
//  PhotosFooterView.swift
//  GalleryDemo
//
//  Created by roman on 21/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

final class PhotosProgressView: UICollectionReusableView {

    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var label: UILabel!

    func showIndicator() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        label.isHidden = true
    }

    func showLabel(_ text: String) {
        label.isHidden = false
        label.text = text
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}
