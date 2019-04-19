//
//  AlbumsViewController.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

protocol AlbumsVCProtocol: class {

    func showProgressIndicator()

    func showProgressLabel(text: String)

    func fetchCompleted()

    func fetchFailed(with: String)
}

final class AlbumsVC: UIViewController {

    @IBOutlet private var tableView: UITableView!

    private var refreshControl: UIRefreshControl!

    private var viewModel: AlbumsVMProtocol!

    private var isRefreshFinishing = false

    private var progressView: ProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = AlbumsVM(viewController: self)

        configureLogoutButton()
        configureRefreshControl()
        configureProgressView()

        viewModel.fetch(as: .load)
    }

    private func configureLogoutButton() {
        let button = UIBarButtonItem(title: "Logout",
                                     style: .done,
                                     target: self,
                                     action: #selector(tapLogoutButton(_:)))
        navigationItem.setLeftBarButton(button, animated: true)
    }

    private func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefreshControl(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func configureProgressView() {
        progressView = ProgressView.nibInstance()
    }

    @objc func tapLogoutButton(_ sender: Any) {
        viewModel.logout()
    }

    @objc func handleRefreshControl(_ sender: Any) {
        viewModel.fetch(as: .reload)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard refreshControl.isRefreshing && isRefreshFinishing else {
            return
        }
        isRefreshFinishing = false
        refreshControl.endRefreshing()
    }

    private func stopRefreshing() {
        guard refreshControl.isRefreshing else {
            return
        }
        if tableView.isDragging {
            isRefreshFinishing = true
        }
        else {
            refreshControl.endRefreshing()
        }
    }
}

extension AlbumsVC: AlbumsVCProtocol {

    func showProgressIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.progressView.showIndicator()
        }
    }

    func showProgressLabel(text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.progressView.showLabel(text: text)
        }
    }

    func fetchCompleted() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.stopRefreshing()
            self.tableView.safeReloadData()
        }
    }

    func fetchFailed(with error: String) {
        DispatchQueue.main.async { [weak self] in
            self?.stopRefreshing()
        }
    }
}

extension AlbumsVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? AlbumsCell {
            let album = viewModel.album(at: indexPath.row)
            cell.configure(album)
        }

        if indexPath.row >= viewModel.count - 10 {
            viewModel.fetch(as: .preload)
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? AlbumsCell {
            cell.cancel()
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return progressView
    }
}

extension AlbumsVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: AlbumsCell.identifier, for: indexPath)
    }
}
