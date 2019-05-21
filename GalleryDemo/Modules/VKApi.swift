//
//  ProfileNetwork.swift
//  GalleryDemo
//
//  Created by roman on 13/05/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import Foundation
import SwiftyVK

enum VKApiError: Error {
    case blank
    case decoder(Error)
    case response(Error)
}

class VKApi {

    var user: UserResponse!

    private var photosResponse: PhotosResponse!

    func getMe(completionHandler: @escaping (Result<UserResponse, VKApiError>) -> Void) {
        VK.API.Users.get([.fields: "has_photo,photo_50"])
            .onSuccess { [weak self] data in
                guard let self = self else { return }

                do {
                    self.user = try self.decoder().decode([UserResponse].self, from: data).first
                    print(self.user)
                    completionHandler(.success(self.user))
                } catch {
                    completionHandler(.failure(.decoder(error)))
                }
            }
            .onError { error in
                completionHandler(.failure(.response(error)))
            }
            .send()
    }

    func getAlbums(_ perPage: Int,
                   _ count: Int,
                   completionHandler: @escaping (Result<AlbumsResponse, VKApiError>) -> Void) {

        let currentPage = count / perPage

        let parameters: Parameters = [.ownerId: String(user.ownerId),
                                      .needCovers: "1",
                                      .photoSizes: "1",
                                      .offset: String(currentPage * perPage),
                                      .count: String(perPage)]

        VK.API.Photos.getAlbums(parameters)
            .onSuccess { [weak self] data in
                guard let self = self else { return }

                do {
                    let response = try self.decoder().decode(AlbumsResponse.self, from: data)
                    completionHandler(.success(response))
                } catch {
                    completionHandler(.failure(.decoder(error)))
                }
            }
            .onError { error in
                completionHandler(.failure(.response(error)))
            }
            .send()
    }

    func getPhotos(_ album: AlbumsResponse.Album,
                   _ perPage: Int,
                   _ count: Int,
                   completionHandler: @escaping (Result<(PhotosResponse, [Int: UserResponse]), VKApiError>) -> Void) {

        photosResponse = nil

        let currentPage = count / perPage

        let parameters: Parameters = [.ownerId: String(album.ownerId),
                                      .albumId: String(album.id),
                                      .rev: "1",
                                      .feedType: "photo",
                                      .photoSizes: "1",
                                      .extended: "1",
                                      .count: String(perPage),
                                      .offset: String(currentPage * perPage)]

        VK.API.Photos.get(parameters)
            .chain { [weak self] data in
                guard let self = self else { throw VKApiError.blank }

                var owners = Set<String>()

                do {
                    let response = try self.decoder().decode(PhotosResponse.self, from: data)

                    for item in response.items {
                        if let userId = item.userId, userId != 100 {
                            owners.insert(String(userId))
                        }
                    }

                    self.photosResponse = response
                } catch {
                    completionHandler(.failure(.decoder(error)))
                }

                return VK.API.Users.get([.userIDs: owners.joined(separator: ","),
                                         .fields: "has_photo, photo_50"])
            }
            .onSuccess { data in
                var users = [Int: UserResponse]()

                do {
                    let response = try self.decoder().decode([UserResponse].self, from: data)

                    for user in response {
                        users[user.id] = user
                    }

                    completionHandler(.success((self.photosResponse, users)))
                } catch {
                    completionHandler(.failure(.decoder(error)))
                }
            }
            .onError { error in
                completionHandler(.failure(.response(error)))
            }
            .send()
    }

    private func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
