//
//  LoginVM.swift
//  GalleryDemo
//
//  Created by roman on 07/05/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import Foundation
import SwiftyVK

protocol LoginVMProtocol: AnyObject {
    var viewController: LoginVCProtocol! { get set }

    func login()
}

class LoginVM {
    weak var viewController: LoginVCProtocol!
}

extension LoginVM: LoginVMProtocol {
    func login() {
        VK.sessions.default.logIn(onSuccess: onSuccess, onError: onError)
    }

    private func onSuccess(data: [String: String]) {
        DispatchQueue.main.async {
            AppDelegate.shared.showNavigationVC()
        }
    }

    private func onError(error: VKError) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController.showAlert("Authorize failed with \(error.localizedDescription)")
        }
    }
}
