//
//  AlbumsViewController.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

protocol AlbumsVCProtocol: class {
    func endRefreshing()
    
    func fetchCompleted()
    
    func fetchFailed(with: String)
}

final class AlbumsVC: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private var viewModel: AlbumsVMProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = AlbumsVM(viewController: self)
        
        configureLogoutButton()
        configureRefreshControl()
        
        
//        viewModel.fetch(refresh: false)
    }
    
    func configureLogoutButton() {
        let button = UIBarButtonItem(title: "Logout",
                                     style: .done,
                                     target: self,
                                     action: #selector(tapLogoutButton(_:)))
        navigationItem.setLeftBarButton(button, animated: true)
    }
    
    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                 action: #selector(refresh(_:)),
                                 for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func tapLogoutButton(_ sender: Any) {
        viewModel.logout()
    }
    
    @objc func refresh(_ sender: Any) {
        viewModel.fetch(refresh: true)
    }
    
    func endRefreshing() {
        guard let refreshControl = tableView.refreshControl,
            refreshControl.isRefreshing else {
                return
        }
        refreshControl.endRefreshing()
    }
}

extension AlbumsVC: AlbumsVCProtocol {
    func fetchCompleted() {
        tableView.reloadData()
        endRefreshing()
    }

    func fetchFailed(with error: String) {
        NotifyManager.shared.failure(error)
        endRefreshing()
    }
}

extension AlbumsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didEndDisplaying cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        
        if let cell = cell as? AlbumsCell {
            cell.cancel()
        }
        
        if indexPath.row > viewModel.countOfAlbums - 6 {
//            viewModel.fetch(refresh: false)
        }
    }
}

extension AlbumsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.countOfAlbums
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let album = viewModel.album(at: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumsCell.reuseIdentifier,
                                                 for: indexPath) as! AlbumsCell
        cell.configure(album)
        return cell
    }
}
