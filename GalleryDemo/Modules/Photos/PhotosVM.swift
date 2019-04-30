//
//  PhotosModel.swift
//  GalleryDemo
//
//  Created by roman on 02/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import SwiftyVK

protocol PhotosVMProtocol: AnyObject {
    var inProgress: Bool { get }

    var isFinished: Bool { get }

    var total: Int { get }

    var count: Int { get }

    var currentPage: Int { get }

    func setAlbum(_ album: AlbumsResponse.Album)

    func setPhotos(_ photos: [PhotosResponse.Photo])

    func photo(at: Int) -> PhotosResponse.Photo?

    func fetch(isRefresh: Bool)
}

final class PhotosVM {
    private let perPage = 100

    private var album: AlbumsResponse.Album!

    private var photos = [PhotosResponse.Photo]()

    private weak var viewController: PhotosVCProtocol?

    private(set) var total = 0

    private(set) var inProgress = false

    private(set) var isFinished = false

    private var parameters: Parameters {
        return [.ownerId: "-41238925",
                .albumId: String(album.id),
                .rev: "1",
                .feedType: "photo",
                .photoSizes: "1",
                .offset: String(currentPage * perPage),
                .count: String(perPage)]
    }

    init(viewController: PhotosVCProtocol, album: AlbumsResponse.Album) {
        self.viewController = viewController
        self.album = album
    }
}

extension PhotosVM: PhotosVMProtocol {
    var count: Int {
        return photos.count
    }

    var currentPage: Int {
        return count / perPage
    }

    func setAlbum(_ album: AlbumsResponse.Album) {
        self.album = album
    }

    func setPhotos(_ photos: [PhotosResponse.Photo]) {
        self.photos = photos
    }

    func photo(at index: Int) -> PhotosResponse.Photo? {
        guard photos.indices.contains(index) else {
            return nil
        }

        fetchIfNeeded(at: index)

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

    private func fetchIfNeeded(at index: Int) {
        guard index >= count - perPage / 2 else {
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
        inProgress = false

        viewController?.showProgressMessage("No internet connection")
        viewController?.fetchFailed(with: "No internet connection")
    }
}
