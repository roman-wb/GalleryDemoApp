//
//  PhotosModel.swift
//  GalleryDemo
//
//  Created by roman on 02/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import SwiftyVK

protocol PhotosVMProtocol: class {

    var inProgress: Bool { get }

    var isFinished: Bool { get }

    var count: Int { get }

    func photo(at: Int) -> PhotosResponse.Photo?

    func fetch(as action: PhotosVM.Action)

    func prefetchIfNeeded(at index: IndexPath)
}

final class PhotosVM {

    enum Action {
        case load, preload, reload
    }

    var album: AlbumsResponse.Album!

    private weak var viewController: PhotosVCProtocol?

    private var photos = [PhotosResponse.Photo]()

    private(set) var inProgress = false

    private(set) var isFinished = false

    private let perPage = 100

    private var currentPage = 0

    private var parameters: Parameters {
        let offset = currentPage * perPage
        return [.ownerId: "-41238925",
                .albumId: String(album.id),
                .rev: "1",
                .feedType: "photo",
                .photoSizes: "1",
                .offset: String(offset),
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

    func photo(at index: Int) -> PhotosResponse.Photo? {
        guard photos.indices.contains(index) else {
            return nil
        }
        return photos[index]
    }

    func fetch(as action: PhotosVM.Action) {
        switch action {
        case _ where inProgress:
            return
        case .preload where isFinished:
            return
        case .load:
            currentPage = 0
            viewController?.showProgressIndicator()
        case .preload:
            currentPage += 1
            viewController?.showProgressIndicator()
        case .reload:
            photos = []
            currentPage = 0
            isFinished = false
            viewController?.showProgressIndicator()
        }

        inProgress = true

        VK.API.Photos.get(parameters)
            .onSuccess(onSuccess)
            .onError(onError)
            .send()
    }

    func prefetchIfNeeded(at indexPath: IndexPath) {
        guard indexPath.row >= count - perPage / 2 else {
            return
        }
        fetch(as: .preload)
    }

    private func onSuccess(_ data: Data) {
        if let response = try? JSONDecoder().decode(PhotosResponse.self, from: data) {
            isFinished = response.count == photos.count

            for var photo in response.items {
                photo.setup()
                photos.append(photo)
            }

            if isFinished {
                if count > 0 {
                    viewController?.showProgressLabel(text: "\(count) photos")
                } else {
                    viewController?.showProgressLabel(text: "Photos not found")
                }
            }

            inProgress = false
            viewController?.fetchCompleted()
        } else {
            inProgress = false
            viewController?.showProgressLabel(text: "Unknown response from API")
            viewController?.fetchFailed(with: "Unknown response from API")
        }
    }

    private func onError(error: VKError) {
        inProgress = false
        viewController?.showProgressLabel(text: "No internet connection")
        viewController?.fetchFailed(with: "No internet connection")
    }
}
