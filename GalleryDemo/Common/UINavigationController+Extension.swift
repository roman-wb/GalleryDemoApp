//
//  UINavigationController+Extension.swift
//  GalleryDemo
//
//  Created by roman on 26/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
