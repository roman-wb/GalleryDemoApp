////
////  ApiResponse.swift
////  GalleryDemo
////
////  Created by roman on 16/04/2019.
////  Copyright © 2019 figma. All rights reserved.
////
//
import Foundation

struct PhotosResponse: Codable {
    var count: Int
    var items: [Photo]

    struct Size: Codable {
        var url: String
        var width: Int
        var height: Int
        var type: String
    }

    struct Photo: Codable {
        var id: Int
        var sizes: [Size]
        var thumbURL: URL?
        var imageURL: URL?

        mutating func setup() {
            thumbURL = URL(string: thumb)
            imageURL = URL(string: image)
        }

        private var thumb: String {
            var size = sizes.last!
            for tmpSize in sizes {
                if tmpSize.width > 200, tmpSize.width < size.width {
                    size = tmpSize
                }
            }
            return size.url
        }

        private var image: String {
            var size = sizes.last!
            for tmpSize in sizes {
                if tmpSize.width > 800, tmpSize.width < size.width {
                    size = tmpSize
                }
            }
            return size.url
        }
    }
}
