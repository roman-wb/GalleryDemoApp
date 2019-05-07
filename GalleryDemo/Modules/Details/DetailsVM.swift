//
//  PhotosModel.swift
//  GalleryDemo
//
//  Created by roman on 02/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import SwiftyVK

final class DetailsVM {
    var album: AlbumsResponse.Album!

    var photos = [PhotosResponse.Photo]()

    private let perPage = 100

    private weak var viewController: DetailsVC!

    var total = 0

    private(set) var inProgress = false

    var isFinished = false

    private var parameters: Parameters {
        return [.ownerId: "-41238925",
                .albumId: String(album.id),
                .rev: "1",
                .feedType: "photo",
                .photoSizes: "1",
                .offset: String(currentPage * perPage),
                .count: String(perPage)]
    }

    init(viewController: DetailsVC) {
        self.viewController = viewController
    }

    var count: Int {
        return photos.count
    }

    var currentPage: Int {
        return count / perPage
    }

    func photo(at index: Int) -> PhotosResponse.Photo? {
        guard photos.indices.contains(index) else {
            return nil
        }

        fetchIfNeeded(at: index)

        return photos[index]
    }

    func fetch() {
        if inProgress || isFinished {
            return
        }

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

        fetch()
    }

    private func onSuccess(_ data: Data) {
        guard let response = try? JSONDecoder().decode(PhotosResponse.self, from: data) else {
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

        viewController?.fetchCompleted()
        inProgress = false
    }

    private func onError(error: VKError) {
        viewController?.fetchFailed(with: "No internet connection")
        inProgress = false
    }
}
