//
//  UIView+Extension.swift
//  GalleryDemo
//
//  Created by roman on 19/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

extension UIView {

    private class func nibInstancePrivate<T: UIView>() -> T? {
        let name = String(describing: self)
        let nib = UINib(nibName: name, bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil).first as? T
    }

    class func nibInstance() -> Self {
        return nibInstancePrivate()!
    }
}
