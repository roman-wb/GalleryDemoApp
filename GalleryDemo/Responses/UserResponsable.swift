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
    var hasPhoto: Int

    var ownerId: Int {
        return -35486195 // id
    }
    var name: String {
        return "\(lastName) \(firstName)"
    }
    var isPhoto: Bool {
        return hasPhoto == 1
    }
}
