//
//  AppDelegate.swift
//  GalleryDemo
//
//  Created by roman on 30/03/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import SwiftyVK

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]
    typealias OpenURLOptions = [UIApplication.OpenURLOptionsKey: Any]

    var window: UIWindow?
    // swiftlint:disable weak_delegate
    var vkDelegate: VKDelegate?
    // swiftlint:enable weak_delegate

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: LaunchOptions? = nil) -> Bool {
        vkDelegate = VKDelegate()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RouterVC.shared
        window?.makeKeyAndVisible()

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: OpenURLOptions = [:]) -> Bool {
        let app = options[.sourceApplication] as? String
        VK.handle(url: url, sourceApplication: app)

        return true
    }
}
