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
        var ownerId: Int
        var title: String
        var sizes: [Size]
        var thumbURL: URL?

        mutating func setup() {
            thumbURL = getImage(200)
        }

        private func getImage(_ width: Int) -> URL? {
            guard var size = sizes.last else { return nil }

            for tmpSize in sizes where tmpSize.width > width && tmpSize.width < size.width {
                size = tmpSize
            }

            return URL(string: size.src)
        }
    }
}
