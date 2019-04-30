//
//  UIViewController+Extension.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

extension UIViewController {
    private class func storyboardInstancePrivate<T: UIViewController>() -> T? {
        let name = String(describing: self)
        let storyboard = UIStoryboard(name: name, bundle: nil)
        return storyboard.instantiateInitialViewController() as? T
    }

    class func storyboardInstance() -> Self {
        return storyboardInstancePrivate()!
    }
}
