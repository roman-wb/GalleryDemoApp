//
//  Album.swift
//  GalleryDemo
//
//  Created by roman on 08/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import Foundation

struct Album: Codable {
    
    struct Response: Codable {
        var count: Int
        var items: [Album]
    }
    
    struct Size: Codable {
        var src: String
        var width: Int
        var height: Int
        var type: String
    }
    
    var title: String
    var description: String?
    var sizes: [Size]
    var thumb: String? {
        return sizes.last?.src
    }
}
