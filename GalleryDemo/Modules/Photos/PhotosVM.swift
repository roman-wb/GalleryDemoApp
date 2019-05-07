//
//  PhotosModel.swift
//  GalleryDemo
//
//  Created by roman on 02/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import SwiftyVK

protocol PhotosVMProtocol {
    var viewController: PhotosVCProtocol? { get set }

    var indexPath: IndexPath? { get set }

    var album: AlbumsResponse.Album! { get set }

    var photos: [PhotosResponse.Photo] { get }

    var count: Int { get }

    var total: Int { get }

    var inProgress: Bool { get }

    var isFinished: Bool { get }

    func photo(at index: Int) -> PhotosResponse.Photo?

    func fetch(isRefresh: Bool)

    func fetchIfNeeded(at indexPath: IndexPath)
}

final class PhotosVM {

    private let perPage = 100

    weak var viewController: PhotosVCProtocol?

    var indexPath: IndexPath?

    var album: AlbumsResponse.Album!

    private(set) var photos = [PhotosResponse.Photo]()

    private(set) var total = 0

    private(set) var inProgress = false

    private(set) var isFinished = false

    private var parameters: Parameters {
        return [.albumId: String(album.id),
                .rev: "1",
                .feedType: "photo",
                .photoSizes: "1",
                .count: String(perPage),
                .offset: String(currentPage * perPage),
                .ownerId: "-41238925"] // FIXME: Remove ownerId
    }

    private var currentPage: Int {
        return count / perPage
    }
}

extension PhotosVM: PhotosVMProtocol {
    var count: Int {
        return photos.count
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

        VK.API.Photos.get(parameters)
            .onSuccess(onSuccess)
            .onError(onError)
            .send()
    }

    func fetchIfNeeded(at indexPath: IndexPath) {
        guard indexPath.row >= count - perPage / 2 else {
            return
        }

        fetch(isRefresh: false)
    }

    private func onSuccess(_ data: Data) {
        guard let response = try? JSONDecoder().decode(PhotosResponse.self, from: data) else {
            viewController?.showProgressMessage("Unknown response from API")
            viewController?.fetchFailed(with: "Unknown response from API")
            inProgress = false
            return
        }

        total = response.count

        for var photo in response.items {
            photo.setup()
            photos.append(photo)
        }

        isFinished = total == count

        if isFinished {
            if count > 0 {
                viewController?.showProgressMessage("\(total) photos")
            } else {
                viewController?.showProgressMessage("Photos not found")
            }
        }

        viewController?.fetchCompleted()

        inProgress = false
    }

    private func onError(error: VKError) {
        viewController?.showProgressMessage("No internet connection")
        viewController?.fetchFailed(with: "No internet connection")

        inProgress = false
    }
}
