//
//  AlbumsViewController.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import CoreData

protocol AlbumsVCProtocol: class {

    func refreshing()

    func fetching()

    func fetchCompleted()

    func fetchFailed(with: String)
}

final class AlbumsVC: UIViewController {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var footerView: UIView!

    private var refreshControl: UIRefreshControl!

    private var viewModel: AlbumsVMProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = AlbumsVM(viewController: self)

        configureLogoutButton()
        configureRefreshControl()
        configureTableView()

        viewModel.fetch(isRefresh: false)
    }

    func configureLogoutButton() {
        let button = UIBarButtonItem(title: "Logout",
                                     style: .done,
                                     target: self,
                                     action: #selector(tapLogoutButton(_:)))
        navigationItem.setLeftBarButton(button, animated: true)
    }

    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
    }

    func configureTableView() {
        tableView.tableHeaderView = nil
        tableView.tableFooterView = nil
    }

    @objc func tapLogoutButton(_ sender: Any) {
        viewModel.logout()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard refreshControl.isRefreshing else {
            return
        }
        viewModel.fetch(isRefresh: true)
    }
}

extension AlbumsVC: AlbumsVCProtocol {

    func refreshing() {
        tableView.tableHeaderView = nil
        tableView.tableFooterView = nil
    }

    func fetching() {
        tableView.tableHeaderView = nil
        tableView.tableFooterView = footerView
    }

    func fetchCompleted() {
        tableView.reloadData()
        finished()
    }

    func fetchFailed(with error: String) {
        NotifyManager.shared.failure(error)
        finished()
    }

    private func finished() {
        if viewModel.count == 0 {
            tableView.tableHeaderView = headerView
        }
        tableView.tableFooterView = nil
        refreshControl.endRefreshing()
    }
}

extension AlbumsVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   didEndDisplaying cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {

        if let cell = cell as? AlbumsCell {
            cell.cancel()
        }

        viewModel.prefetch(by: indexPath)
    }
}

extension AlbumsVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumsCell.identifier, for: indexPath)
        if let cell = cell as? AlbumsCell {
            cell.configure(viewModel, with: indexPath)
        }
        return cell
    }
}
