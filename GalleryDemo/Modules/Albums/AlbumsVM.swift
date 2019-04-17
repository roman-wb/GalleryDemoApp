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

    func album(at: Int) -> AlbumsResponse.Album

    func fetch(isRefresh: Bool)

    func prefetchIfNeeded(by indexPath: IndexPath)
}

class AlbumsVM {

    private weak var viewController: AlbumsVCProtocol!

    private var albums = [AlbumsResponse.Album]()

    private(set) var inProgress = false

    private(set) var isFinished = false

    private let perPage = 20

    private var currentPage = 1

    private var parameters: Parameters {
        let offset = (currentPage - 1) * perPage
        return [.needCovers: "1",
                .photoSizes: "1",
                .count: String(perPage),
                .offset: String(offset),
                .ownerId: "-41238925"]
    }

    init(viewController: AlbumsVCProtocol) {
        self.viewController = viewController
    }
}

extension AlbumsVM: AlbumsVMProtocol {

    var count: Int {
        return albums.count
    }

    func logout() {
        VK.sessions.default.logOut()
        RouterVC.shared.toLogin()
    }

    func album(at index: Int) -> AlbumsResponse.Album {
        return albums[index]
    }

    func fetch(isRefresh: Bool = false) {
        if inProgress || isFinished { return }

        inProgress = true

        if isRefresh {
            isFinished = false
            currentPage = 1
        }

        VK.API.Photos.getAlbums(parameters)
            .onSuccess(onSuccess)
            .onError(onError)
            .send()
    }

    func prefetchIfNeeded(by indexPath: IndexPath) {
        let pointer = count - perPage / 2
        guard indexPath.row >= pointer else {
            return
        }
        fetch(isRefresh: false)
    }

    private func onSuccess(_ data: Data) {
        if let response = try? JSONDecoder().decode(AlbumsResponse.self, from: data) {
            isFinished = response.count == 0

            for album in response.items {
                albums.append(album)
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
