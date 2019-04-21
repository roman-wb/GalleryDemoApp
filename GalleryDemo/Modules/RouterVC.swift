//
//  ViewController.swift
//  GalleryDemo
//
//  Created by roman on 30/03/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import SwiftyVK

final class RouterVC: UIViewController {

    static let shared = RouterVC()

    private(set) var currentViewController: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        switch VK.sessions.default.state {
        case .authorized:
            toMain()
        default:
            toLogin()
        }
    }

    func to(_ viewController: UIViewController) {
        addChild(viewController)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)

        if let currentViewController = currentViewController {
            currentViewController.willMove(toParent: nil)
            currentViewController.view.removeFromSuperview()
            currentViewController.removeFromParent()
        }

        currentViewController = viewController
    }

    func toLogin() {
        let currentViewController = LoginVC.storyboardInstance()
        to(currentViewController)
    }

    func toMain() {
        let viewController = AlbumsVC.storyboardInstance()
//        let viewController = PhotosVC.storyboardInstance()
        let navigationViewController = UINavigationController(rootViewController: viewController)
        to(navigationViewController)
    }
}
