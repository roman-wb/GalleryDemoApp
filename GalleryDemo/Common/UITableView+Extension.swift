//
//  UITableView+Extension.swift
//  GalleryDemo
//
//  Created by roman on 20/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

extension UITableView {

    func safeReloadData() {
        let offset = contentOffset
        reloadData()
        contentOffset = offset
    }
}
