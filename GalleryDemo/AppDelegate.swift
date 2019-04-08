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
    
    var window: UIWindow?
    var vkDelegate: SwiftyVKDelegate?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
        ) -> Bool {
        
        vkDelegate = VKDelegate()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RouterVC.shared
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
        ) -> Bool {
        let app = options[.sourceApplication] as? String
        VK.handle(url: url, sourceApplication: app)
        return true
    }
}
