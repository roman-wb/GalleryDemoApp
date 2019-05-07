//
//  AppDelegate.swift
//  GalleryDemo
//
//  Created by roman on 30/03/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import SwiftyVK
import Swinject

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]
    typealias OpenURLOptions = [UIApplication.OpenURLOptionsKey: Any]

    // swiftlint:disable force_cast
    static let shared = UIApplication.shared.delegate as! AppDelegate
    // swiftlint:enable force_cast

    var window: UIWindow?
    var container: Container!
    // swiftlint:disable weak_delegate
    var vkDelegate: VKDelegate!
    // swiftlint:enable weak_delegate

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: LaunchOptions? = nil) -> Bool {
        buildContainer()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        vkDelegate = VKDelegate()

        switch VK.sessions.default.state {
        case .authorized:
            showNavigationVC()
        default:
            showLoginVC()
        }

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: OpenURLOptions = [:]) -> Bool {
        if let app = options[.sourceApplication] as? String {
            VK.handle(url: url, sourceApplication: app)
        }

        return true
    }

    func showLoginVC() {
        window?.rootViewController = container.resolve(LoginVC.self)
    }

    func showNavigationVC() {
        window?.rootViewController = container.resolve(UINavigationController.self)
    }
}

extension AppDelegate {
    func buildContainer() {
        let container = Container()

        // Login
        container.register(LoginVC.self) { resovler in
            let loginVC = LoginVC.storyboardInstance()
            loginVC.viewModel = resovler.resolve(LoginVMProtocol.self)!
            loginVC.viewModel.viewController = loginVC
            return loginVC
        }
        container.register(LoginVMProtocol.self) { _ in LoginVM() }

        // Navigation
        container.register(UINavigationController.self) { resovler in
            let albumsVC = resovler.resolve(AlbumsVC.self)!
            return UINavigationController(rootViewController: albumsVC)
        }

        // Albums
        container.register(AlbumsVC.self) { resovler in
            let albumsVC = AlbumsVC.storyboardInstance()
            albumsVC.container = container
            albumsVC.viewModel = resovler.resolve(AlbumsVMProtocol.self)!
            albumsVC.viewModel.viewController = albumsVC
            return albumsVC
        }
        container.register(AlbumsVMProtocol.self) { _ in AlbumsVM() }

        // Photos
        container.register(PhotosVC.self) { (resovler, album: AlbumsResponse.Album) -> PhotosVC in
            let photosVC = PhotosVC.storyboardInstance()
            photosVC.container = container
            photosVC.viewModel = resovler.resolve(PhotosVMProtocol.self)!
            photosVC.viewModel.viewController = photosVC
            photosVC.viewModel.album = album
            return photosVC
        }
        container.register(PhotosVMProtocol.self) { _ in PhotosVM() }

        // Details
        container.register(DetailsVC.self) { (_, photosVM: PhotosVMProtocol!) -> DetailsVC in
            let detailsVC = DetailsVC.storyboardInstance()
            detailsVC.container = container
            detailsVC.viewModel = photosVM
            return detailsVC
        }

        // ImageLoader
        container.register(ImageLoaderProtocol.self) { resovler in
            let imageLoader = ImageLoader()
            imageLoader.cache = resovler.resolve(NSCache.self, name: "Image")
            return imageLoader
        }

        // Cache
        container.register(NSCache.self, name: "Image") { _ in
            return NSCache<NSString, UIImage>()
        }.inObjectScope(.container)

        self.container = container
    }
}
