//
//  ApiResponse.swift
//  GalleryDemo
//
//  Created by roman on 16/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import Foundation

extension AlbumsVM {

    struct ApiResponse: Codable {
        var count: Int
        var items: [Album]

        // swiftlint:disable nesting
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
            var thumb: String? {
                return sizes.last?.src
            }
        }
        // swiftlint:enable nesting
    }
}
