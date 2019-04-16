//
//  AlbumsModel.swift
//  GalleryDemo
//
//  Created by roman on 02/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import SwiftyVK

protocol AlbumsVMProtocol: class {

    var inProgress: Bool { get }

    var isFinished: Bool { get }

    var count: Int { get }

    func logout()

    func album(at: Int) -> Album?

    func fetch(isRefresh: Bool)

    func prefetch(by indexPath: IndexPath)
}

class AlbumsVM {

    private weak var viewController: AlbumsVCProtocol!

    private(set) var inProgress = false

    private(set) var isFinished = false

    private var currentPage = 1

    private var itemsOnPage = 20

    private var parameters: Parameters {
        let offset = (currentPage - 1) * itemsOnPage

        return [.needCovers: "1", .photoSizes: "1", .count: String(itemsOnPage),
                .offset: String(offset), .ownerId: "-41238925"]
    }

    init(viewController: AlbumsVCProtocol) {
        self.viewController = viewController
    }
}

extension AlbumsVM: AlbumsVMProtocol {

    var count: Int {
        return Album.count()
    }

    func logout() {
        VK.sessions.default.logOut()
        RouterVC.shared.toLogin()
    }

    func album(at index: Int) -> Album? {
        return Album.first(offset: index)
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

        VK.API.Photos.getAlbums(parameters)
            .onSuccess(onSuccess)
            .onError(onError)
            .send()
    }

    func prefetch(by indexPath: IndexPath) {
        guard indexPath.row >= count - 6 else {
            return
        }
        fetch(isRefresh: false)
    }

    private func onSuccess(_ data: Data) {
        if let response = try? JSONDecoder().decode(ApiResponse.self, from: data) {
            isFinished = response.count == 0

            for item in response.items {
                Album.create(id: item.id,
                             title: item.title,
                             thumb: item.thumb)
            }

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
