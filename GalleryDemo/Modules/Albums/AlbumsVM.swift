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

    func fetch(as action: AlbumsVM.Action)
}

class AlbumsVM {

    enum Action {
        case load, preload, reload
    }

    private weak var viewController: AlbumsVCProtocol!

    private var albums = [AlbumsResponse.Album]()

    private(set) var inProgress = false

    private(set) var isFinished = false

    private let perPage = 25

    private var currentPage = 0

    private var parameters: Parameters {
        let offset = currentPage * perPage
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

    func fetch(as action: AlbumsVM.Action) {
        switch action {
        case _ where inProgress:
            return
        case .preload where isFinished:
            return
        case .load:
            currentPage = 0
            viewController.showProgressIndicator()
        case .preload:
            currentPage += 1
            viewController.showProgressIndicator()
        case .reload:
            albums.removeAll()
            currentPage = 0
            isFinished = false
            viewController.showProgressIndicator()
        }

        inProgress = true

        VK.API.Photos.getAlbums(parameters)
            .onSuccess(onSuccess)
            .onError(onError)
            .send()
    }

    private func onSuccess(_ data: Data) {
        if let response = try? JSONDecoder().decode(AlbumsResponse.self, from: data) {
            isFinished = response.count == 0

            for var album in response.items {
                album.setup()
                albums.append(album)
            }

            if isFinished {
                if count > 0 {
                    viewController.showProgressLabel(text: "Total albums \(count)")
                } else {
                    viewController.showProgressLabel(text: "Albums not found")
                }
            }

            inProgress = false
            viewController.fetchCompleted()
        } else {
            inProgress = false
            viewController.showProgressLabel(text: "Unknown response from API")
            viewController.fetchFailed(with: "Unknown response from API")
        }
    }

    private func onError(error: VKError) {
        inProgress = false
        viewController.showProgressLabel(text: "No internet connection")
        viewController.fetchFailed(with: "No internet connection")
    }
}
