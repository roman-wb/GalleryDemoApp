//
//  UIViewController+Extension.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

extension UIViewController {

    class func storyboardInstance<T: UIViewController>() -> T {
        let name = String(describing: self)
        let storyboard = UIStoryboard(name: name, bundle: nil)
        // swiftlint:disable force_cast
        return storyboard.instantiateInitialViewController() as! T
        // swiftlint:enable
    }
}
