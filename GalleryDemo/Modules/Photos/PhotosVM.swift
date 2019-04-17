//
//  AlbumsModel.swift
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

    func photo(at: Int) -> Photo?

    func fetch(isRefresh: Bool)

    func prefetch(by indexPath: IndexPath)
}

class PhotosVM {

    private var album: Album!

    private weak var viewController: PhotosVCProtocol!

    private(set) var inProgress = false

    private(set) var isFinished = false

    private var currentPage = 1

    private var itemsOnPage = 20

    private var parameters: Parameters {
        let offset = (currentPage - 1) * itemsOnPage
        return [.albumId: String(album.id), .rev: "1", .extended: "1", .feedType: "photo", .photoSizes: "1",
                .offset: String(offset), .count: "100", .ownerId: "-41238925"]
    }

    init(_ album: Album, viewController: PhotosVCProtocol) {
        self.album = album
        self.viewController = viewController
    }
}

extension PhotosVM: PhotosVMProtocol {

    var count: Int {
        return 0 // album.photos.count()
    }

    func photo(at index: Int) -> Photo? {
        return nil // album.photos.first(offset: index)
    }

    func fetch(isRefresh: Bool = false) {
        if inProgress || isFinished { return }

        inProgress = true

        if isRefresh {
            isFinished = false
            currentPage = 1

            viewController.refreshing()
        } else {
            viewController.fetching()
        }

        VK.API.Photos.get(parameters)
            .onSuccess(onSuccess)
            .onError(onError)
            .send()
    }

    func prefetch(by indexPath: IndexPath) {
        guard indexPath.row >= count - 100 else {
            return
        }
        fetch(isRefresh: false)
    }

    private func onSuccess(_ data: Data) {
        //print(String(data: data, encoding: .utf8))

        if let response = try? JSONDecoder().decode(ApiResponse.self, from: data) {
            isFinished = response.count == 0

//            for item in response.items {
//                album.photos.create(id: item.id,
//                                    title: item.title,
//                                    thumb: item.thumb)
//            }

            currentPage += 1

            DispatchQueue.main.async { [weak self] in
                self?.inProgress = false
                self?.viewController.fetchCompleted()
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.inProgress = false
                self?.viewController.fetchFailed(with: "Unknown API response")
            }
        }
    }

    private func onError(error: VKError) {
        DispatchQueue.main.async { [weak self] in
            self?.inProgress = false
            self?.viewController.fetchFailed(with: "Not connection")
        }
    }
}
