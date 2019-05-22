//
//  AlbumsDownloader.swift
//  GalleryDemo
//
//  Created by roman on 02/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

class WebImageView: UIImageView {

    static let cache = NSCache<NSString, UIImage>()

    private let size = CGSize(width: 800, height: 800)

    private let indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        return indicatorView
    }()

    private var url: URL!
    private var didChange: (() -> Void)!

    private var task: URLSessionDataTask!

    private func cacheKey() -> NSString {
        return self.url.relativeString as NSString
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setImage(url: URL?, style: UIActivityIndicatorView.Style = .gray, didChange: (() -> Void)? = nil) {
        self.url = url
        self.indicatorView.style = style
        self.didChange = didChange

        task?.cancel()
        indicatorView.stopAnimating()

        if url == nil {
            image = nil
            didChange?()
            return
        }

        image = WebImageView.cache.object(forKey: cacheKey())

        guard image == nil else {
            didChange?()
            return
        }

        indicatorView.startAnimating()

        task = URLSession.shared.dataTask(with: self.url, completionHandler: completionHandler)
        task?.resume()
    }

    private func setup() {
        addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func completionHandler(data: Data?, response: URLResponse?, error: Error?) {
        guard error == nil else { return }
        guard
            let data = data,
            let image = UIImage(data: data),
            let resizedImage = image.resize(size) else {
                return
        }

        WebImageView.cache.setObject(resizedImage, forKey: cacheKey())

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.image = resizedImage
            self.indicatorView.stopAnimating()
            self.didChange?()
        }
    }
}
