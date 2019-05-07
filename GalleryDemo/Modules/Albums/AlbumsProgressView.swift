//
//  ProgressView.swift
//  GalleryDemo
//
//  Created by roman on 19/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

class AlbumsProgressView: UIView {

    @IBOutlet private var indicator: UIActivityIndicatorView!
    @IBOutlet private var label: UILabel!

    func showIndicator() {
        indicator.startAnimating()
        indicator.isHidden = false
        label.isHidden = true
    }

    func showLabel(text: String) {
        label.isHidden = false
        label.text = text
        indicator.stopAnimating()
        indicator.isHidden = true
    }
}
