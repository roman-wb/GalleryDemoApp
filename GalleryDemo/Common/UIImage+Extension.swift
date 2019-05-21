//
//  UIImage+Extension.swift
//  GalleryDemo
//
//  Created by roman on 17/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

extension UIImage {

    convenience init?(data: Data, resize: CGSize) {
        guard
            let image = UIImage(data: data),
            let resizedImage = image.resize(resize),
            let resizedData = resizedImage.jpegData(compressionQuality: 1) else {
                return nil
        }
        self.init(data: resizedData)
    }

    func resize(_ resize: CGSize, opaque: Bool = true) -> UIImage? {
        let widthRatio = resize.width / size.width
        let heightRatio = resize.height / size.height

        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        let rect = CGRect(origin: .zero, size: newSize)

        UIGraphicsBeginImageContextWithOptions(newSize, opaque, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
