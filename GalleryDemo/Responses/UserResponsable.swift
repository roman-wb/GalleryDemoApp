//
//  ProfileResponse.swift
//  GalleryDemo
//
//  Created by roman on 08/05/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import Foundation

struct UserResponse: Codable {
    var id: Int
    var firstName: String
    var lastName: String
    var photo50: String

    var avatarURL: URL? {
        return URL(string: photo50)
    }
    var ownerId: Int {
        return -35486195 // id
    }
    var name: String {
        return "\(lastName) \(firstName)"
    }
}
