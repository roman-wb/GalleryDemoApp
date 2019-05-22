//
//  PhotosModel.swift
//  GalleryDemo
//
//  Created by roman on 02/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

protocol PhotosVMProtocol {
    var api: VKApi! { get set }
    var viewController: PhotosVCProtocol! { get set }

    var indexPath: IndexPath! { get set }
    var album: AlbumsResponse.Album! { get set }
    var photos: [PhotosResponse.Photo] { get set }
    var users: [Int: UserResponse] { get set }

    var currentIndex: Int { get }
    var count: Int { get }
    var total: Int { get }

    var inProgress: Bool { get }
    var isFinished: Bool { get }

    func avatarURLBy(_ photo: PhotosResponse.Photo) -> URL?
    func fullnameBy(_ photo: PhotosResponse.Photo) -> String
    func photo(at index: Int) -> PhotosResponse.Photo?
    func fetch(isRefresh: Bool)
    func fetchIfNeeded(at indexPath: IndexPath)
}

final class PhotosVM {

    let perPage = 100

    var api: VKApi!
    weak var viewController: PhotosVCProtocol!

    var indexPath: IndexPath!
    var album: AlbumsResponse.Album!
    var photos = [PhotosResponse.Photo]()
    var users = [Int: UserResponse]()

    var currentIndex: Int {
        return indexPath.row + 1
    }

    var count: Int {
        return photos.count
    }

    private(set) var total = 0
    private(set) var inProgress = false
    private(set) var isFinished = false
}

extension PhotosVM: PhotosVMProtocol {

    func avatarURLBy(_ photo: PhotosResponse.Photo) -> URL? {
        if let userId = photo.userId, let user = users[userId] {
            return user.avatarURL
        } else if let user = users[photo.ownerId] {
            return user.avatarURL
        } else {
            return album.thumbURL
        }
    }

    func fullnameBy(_ photo: PhotosResponse.Photo) -> String {
        if let userId = photo.userId, let user = users[userId] {
            return user.name
        } else if let user = users[photo.ownerId] {
            return user.name
        } else {
            return album.title
        }
    }

    func photo(at index: Int) -> PhotosResponse.Photo? {
        guard photos.indices.contains(index) else {
            return nil
        }

        return photos[index]
    }

    func fetch(isRefresh: Bool) {
        if isRefresh {
            photos = []
            isFinished = false
        }

        if inProgress || isFinished {
            return
        }

        viewController?.showProgressIndicator()

        inProgress = true

        api.getPhotos(album, perPage, count) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                self.onSuccess(response)
            case .failure(.decoder):
                self.onError(message: "Unknown response from API")
            case .failure(.response):
                self.onError(message: "No internet connection")
            default:
                self.onError(message: "Unknown error")
            }
        }
    }

    func fetchIfNeeded(at indexPath: IndexPath) {
        guard indexPath.row >= count - perPage / 2 else {
            return
        }

        fetch(isRefresh: false)
    }

    private func onSuccess(_ response: (photos: PhotosResponse, users: [Int: UserResponse])) {
        users.merge(response.users) { current, _ in current }
        photos.append(contentsOf: response.photos.items)

        total = response.photos.count

        isFinished = total == count

        if isFinished {
            if count > 0 {
                viewController.showProgressMessage("\(total) photos")
            } else {
                viewController.showProgressMessage("Photos not found")
            }
        }

        viewController.fetchCompleted()

        inProgress = false
    }

    private func onError(message: String) {
        viewController.showProgressMessage(message)
        viewController.fetchFailed()

        inProgress = false
    }
}
