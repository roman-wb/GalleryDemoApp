//
//  AlbumsViewController.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import Swinject

protocol AlbumsVCProtocol: AnyObject {
    var api: VKApi! { get set }
    var container: Container! { get set }
    var viewModel: AlbumsVMProtocol! { get set }

    func showProgressIndicator()
    func showProgressMessage(_ message: String)

    func fetchCompleted()
    func fetchFailed()
}

final class AlbumsVC: UIViewController {

    @IBOutlet private var tableView: UITableView!

    var api: VKApi!
    var container: Container!
    var viewModel: AlbumsVMProtocol!

    private var refreshControl: UIRefreshControl!
    private var isRefreshFinishing = false
    private var progressView: AlbumsProgressView!

    override func viewDidLoad() {
        configureRefreshControl()
        configureProgressView()

        viewModel.loading { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success:
                    self?.configureLogoutButton()
                    self?.viewModel.fetch(isRefresh: false)
                default:
                    fatalError("Not load current user!")
                }
            }
        }
    }

    private func configureLogoutButton() {
        let button = UIBarButtonItem(title: "Logout \(api.user.name)",
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
        progressView = AlbumsProgressView.nibInstance()
    }

    @objc func tapLogoutButton(_ sender: Any) {
        viewModel.logout()
    }

    @objc func handleRefreshControl(_ sender: Any) {
        viewModel.fetch(isRefresh: true)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard refreshControl.isRefreshing, isRefreshFinishing else {
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
        } else {
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

    func showProgressMessage(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.progressView.showLabel(text: message)
        }
    }

    func fetchCompleted() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.safeReloadData()
            self?.stopRefreshing()
        }
    }

    func fetchFailed() {
        DispatchQueue.main.async { [weak self] in
            self?.stopRefreshing()
        }
    }
}

extension AlbumsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let album = viewModel.album(at: indexPath.row) else {
            return
        }

        let photosVC = container.resolve(PhotosVC.self, argument: album)!
        navigationController?.pushViewController(photosVC, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.fetchIfNeeded(at: indexPath)

        guard let cell = cell as? AlbumsCell, let album = viewModel.album(at: indexPath.row) else {
            return
        }

        cell.configure(container: container, album: album)
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? AlbumsCell else {
            return
        }

        cell.didEndDisplaying()
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
