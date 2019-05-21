//
//  AlbumsCell.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import Swinject

final class DetailsCell: UICollectionViewCell {

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: WebImageView!

    private var container: Container!
    private var photo: PhotosResponse.Photo!

    func configure(container: Container, photo: PhotosResponse.Photo) {
        self.container = container
        self.photo = photo

        imageView.setImage(url: photo.thumbURL) { [weak self] in
            self?.updateZoom()
            self?.updateInsets()
        }
    }

    func updateZoom() {
        scrollView.zoomScale = 1.0

        guard let image = imageView.image else { return }

        let widthRatio = (frame.width - 20) / image.size.width
        let heightRatio = (frame.height - 20) / image.size.height
        let scale = min(widthRatio, heightRatio)
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        imageView.frame = CGRect(origin: .zero, size: size)
        scrollView.contentSize = size
    }

    func updateInsets() {
        let offsetX = max((scrollView.frame.width - imageView.frame.width) / 2, 0)
        let offsetY = max((scrollView.frame.height - imageView.frame.height) / 2, 0)

        scrollView.alwaysBounceHorizontal = offsetX == 0
        scrollView.alwaysBounceVertical = offsetY == 0

        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}

extension DetailsCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateInsets()
    }
}
