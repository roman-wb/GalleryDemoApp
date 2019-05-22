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

        resetImageView()
        imageView.setImage(url: photo.imageURL, style: .whiteLarge) { [weak self] in
            self?.updateZoom()
            self?.updateInsets()
        }
    }

    private func resetImageView() {
        scrollView.zoomScale = 1.0
        scrollView.contentSize = frame.size
        imageView.frame = bounds
        updateInsets()
    }

    private func updateZoom() {
        guard let image = imageView.image else { return }

        let widthScale = (frame.width - 20) / image.size.width
        let heightScale = (frame.height - 20) / image.size.height
        let scale = min(widthScale, heightScale)

        let newWidth = (image.size.width * scale).rounded(.down)
        let newHeight = (image.size.height * scale).rounded(.down)
        let size = CGSize(width: newWidth, height: newHeight)

        scrollView.contentSize = size
        imageView.frame = CGRect(origin: .zero, size: size)
    }

    private func updateInsets() {
        let offsetX = max((frame.width - imageView.frame.width) / 2, 0)
        let offsetY = max((frame.height - imageView.frame.height) / 2, 0)

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
