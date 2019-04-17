//
//  UIImage+Extension.swift
//  GalleryDemo
//
//  Created by roman on 17/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

extension UIImage {

    func resize(_ resize: CGSize) -> UIImage? {
        let widthRatio = resize.width / size.width
        let heightRatio = resize.height / size.height

        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
