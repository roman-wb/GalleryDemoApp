//
//  ApiResponse.swift
//  GalleryDemo
//
//  Created by roman on 16/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import Foundation

extension PhotosVM {

    struct ApiResponse: Codable {
        var count: Int
        var items: [Photo]

        // swiftlint:disable nesting
        struct Size: Codable {
            var url: String
            var width: Int
            var height: Int
            var type: String
        }

        struct Photo: Codable {
            var id: Int
            var sizes: [Size]
            var thumb: String? {
                return sizes.last?.url
            }
        }
        // swiftlint:enable nesting
    }
}
