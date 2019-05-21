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
    var api: VKApi! { get set }
    var viewController: AlbumsVCProtocol! { get set }

    var count: Int { get }
    var inProgress: Bool { get }
    var isFinished: Bool { get }

    func logout()
    func loading(completionHandler: @escaping (Result<UserResponse, VKApiError>) -> Void)
    func album(at: Int) -> AlbumsResponse.Album?

    func fetch(isRefresh: Bool)
    func fetchIfNeeded(at indexPath: IndexPath)
}

final class AlbumsVM {

    private let perPage = 30

    var api: VKApi!
    weak var viewController: AlbumsVCProtocol!

    var count: Int {
        return albums.count
    }

    private var albums = [AlbumsResponse.Album]()

    private(set) var inProgress = false
    private(set) var isFinished = false
}

extension AlbumsVM: AlbumsVMProtocol {
    func loading(completionHandler: @escaping (Result<UserResponse, VKApiError>) -> Void) {
        api.getMe { completionHandler($0) }
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

        viewController.showProgressIndicator()

        inProgress = true

        api.getAlbums(perPage, count) { [weak self] result in
            switch result {
            case .success(let response):
                self?.onSuccess(response)
            case .failure(.decoder):
                self?.onError(message: "Unknown response from API")
            case .failure(.response):
                self?.onError(message: "No internet connection")
            default:
                self?.onError(message: "Unknown error")
            }
        }
    }

    func fetchIfNeeded(at indexPath: IndexPath) {
        guard indexPath.row >= count - perPage / 2 else {
            return
        }

        fetch(isRefresh: false)
    }

    private func onSuccess(_ response: AlbumsResponse) {
        for album in response.items {
            albums.append(album)
        }

        isFinished = response.count < perPage

        if isFinished {
            if count > 0 {
                viewController.showProgressMessage("\(count) albums")
            } else {
                viewController.showProgressMessage("Albums not found")
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
