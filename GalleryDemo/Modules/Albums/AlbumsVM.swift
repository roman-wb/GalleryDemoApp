//
//  AlbumsModel.swift
//  GalleryDemo
//
//  Created by roman on 02/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import SwiftyVK

protocol AlbumsVMProtocol: AnyObject {
    var viewController: AlbumsVCProtocol! { get set }

    var inProgress: Bool { get }

    var isFinished: Bool { get }

    var count: Int { get }

    func logout()

    func album(at: Int) -> AlbumsResponse.Album?

    func fetch(isRefresh: Bool)

    func fetchIfNeeded(at indexPath: IndexPath)
}

final class AlbumsVM {

    private let perPage = 30

    weak var viewController: AlbumsVCProtocol!

    private var albums = [AlbumsResponse.Album]()

    private(set) var inProgress = false

    private(set) var isFinished = false

    private var parameters: Parameters {
        return [.needCovers: "1",
                .photoSizes: "1",
                .offset: String(currentPage * perPage),
                .count: String(perPage),
                .ownerId: "-41238925"] // FIXME: Remove ownerId
    }

    private var currentPage: Int {
        return count / perPage
    }
}

extension AlbumsVM: AlbumsVMProtocol {
    var count: Int {
        return albums.count
    }

    func logout() {
        VK.sessions.default.logOut()
        AppDelegate.shared.showLoginVC()
    }

    func album(at index: Int) -> AlbumsResponse.Album? {
        guard albums.indices.contains(index) else {
            return nil
        }

        return albums[index]
    }

    func fetch(isRefresh: Bool) {
        if isRefresh {
            albums = []
            isFinished = false
        }

        if inProgress || isFinished {
            return
        }

        viewController?.showProgressIndicator()

        inProgress = true

        VK.API.Photos.getAlbums(parameters)
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
        guard let response = try? JSONDecoder().decode(AlbumsResponse.self, from: data) else {
            viewController?.showProgressMessage("Unknown response from API")
            viewController?.fetchFailed(with: "Unknown response from API")
            inProgress = false
            return
        }

        for var album in response.items {
            album.setup()
            albums.append(album)
        }

        isFinished = response.count < perPage

        if isFinished {
            if count > 0 {
                viewController?.showProgressMessage("\(count) photos")
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
