//
//  ApiResponse.swift
//  GalleryDemo
//
//  Created by roman on 16/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import Foundation

struct AlbumsResponse: Codable {
    var count: Int
    var items: [Album]

    struct Size: Codable {
        var src: String
        var width: Int
        var height: Int
        var type: String
    }

    struct Album: Codable {
        var id: Int
        var title: String
        var sizes: [Size]
        var thumbURL: URL?

        mutating func setup() {
            thumbURL = URL(string: thumb)
        }

        private var thumb: String {
            var size = sizes.last!
            for tmpSize in sizes {
                if tmpSize.width > 800, tmpSize.width < size.width {
                    size = tmpSize
                }
            }
            return size.src
        }
    }
}
