//
//  LoginController.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

protocol LoginVCProtocol: class {
    func showAlert(_ message: String)
}

final class LoginVC: UIViewController {
    
    private var viewModel: LoginVMProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = LoginVM(viewController: self)
    }
    
    @IBAction func tapLoginButton(_ sender: UIButton) {
        viewModel.login()
    }
}

extension LoginVC: LoginVCProtocol {
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: message,
                                                message: nil,
                                                preferredStyle: .alert)

        let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            guard let self = self else { return }

            self.viewModel.login()
        }
        alertController.addAction(retryAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}
