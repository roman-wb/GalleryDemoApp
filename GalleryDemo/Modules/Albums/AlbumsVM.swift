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
    var countOfAlbums: Int { get }

    func logout()
    
    func fetch(refresh: Bool)
    
    func album(at: Int) -> Album
}

class AlbumsVM {
    
    private weak var viewController: AlbumsVCProtocol!

    private var albums = [Album]()

    private var inProgress = false

    private var isFinished = false

    private var currentPage = 1

    private var countOfPage = 20

    private var offsetPage: Int {
        return (currentPage - 1) * countOfPage
    }

    private var parameters: Parameters {
        return [.needCovers: "1", .photoSizes: "1", .count: String(countOfPage),
                .offset: String(offsetPage), .ownerId: "-41238925"]
    }

    init(viewController: AlbumsVCProtocol) {
        self.viewController = viewController
    }
}

extension AlbumsVM: AlbumsVMProtocol {
    var countOfAlbums: Int {
        return albums.count
    }
    
    func logout() {
        VK.sessions.default.logOut()
        RouterVC.shared.toLogin()
    }
    
    func fetch(refresh: Bool = false) {
        if refresh {
            isFinished = false
            currentPage = 1
        }

        if inProgress || isFinished { return }

        inProgress = true

        VK.API.Photos.getAlbums(parameters)
            .onSuccess { [weak self] in
                guard let self = self else { return }

                self.inProgress = false

                if let response = try? JSONDecoder().decode(Album.Response.self, from: $0) {
                    self.isFinished = response.items.count == 0

                    if refresh {
                        self.albums = response.items
                    } else {
                        self.albums.append(contentsOf: response.items)
                    }

                    self.currentPage += 1
                
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        self.viewController.fetchCompleted()
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }

                        self.viewController.fetchFailed(with: "Unknown API response")
                    }
                }
            }
            .onError { [weak self] error in
                guard let self = self else { return }

                self.inProgress = false

                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }

                    self.viewController.fetchFailed(with: "No internet connection")
                }
            }
            .send()
    }
    
    func album(at index: Int) -> Album {
        return albums[index]
    }
}
