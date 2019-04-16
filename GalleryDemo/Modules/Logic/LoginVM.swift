//
//  LoginViewModel.swift
//  GalleryDemo
//
//  Created by roman on 08/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import SwiftyVK

protocol LoginVMProtocol: class {

    func login()
}

final class LoginVM {

    private weak var viewController: LoginVCProtocol!

    init(viewController: LoginVCProtocol) {
        self.viewController = viewController
    }
}

extension LoginVM: LoginVMProtocol {

    func login() {
        VK.sessions.default.logIn(onSuccess: onSuccess, onError: onError)
    }

    private func onSuccess(data: [String: String]) {
        DispatchQueue.main.async {
            RouterVC.shared.toMain()
        }
    }

    private func onError(error: VKError) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController.showAlert("Authorize failed with \(error.localizedDescription)")
        }
    }
}
