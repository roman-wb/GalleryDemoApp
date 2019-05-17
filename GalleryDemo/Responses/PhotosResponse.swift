//
//  ApiResponse.swift
//  GalleryDemo
//
//  Created by roman on 16/04/2019.
//  Copyright © 2019 figma. All rights reserved.
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

    struct Countable: Codable {
        var count: Int
    }

    struct Photo: Codable {
        var id: Int
        var ownerId: Int
        var userId: Int?
        var date: Int
        var likes: Countable
        var reposts: Countable
        var comments: Countable
        var sizes: [Size]

        var thumbURL: URL?
        var imageURL: URL?

        var likesCount: Int {
            return likes.count
        }
        var repostsCount: Int {
            return reposts.count
        }
        var commentsCount: Int {
            return comments.count
        }

        mutating func setup() {
            thumbURL = getImage(200)
            imageURL = getImage(800)
        }

        private func getImage(_ width: Int) -> URL? {
            guard var size = sizes.last else { return nil }

            for tmpSize in sizes where tmpSize.width > width && tmpSize.width < size.width {
                size = tmpSize
            }

            return URL(string: size.url)
        }
    }
}
