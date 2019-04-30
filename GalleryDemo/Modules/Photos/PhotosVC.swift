//
//  PhotosViewController.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

protocol PhotosVCProtocol: AnyObject {
    func setAlbum(_ album: AlbumsResponse.Album)

    func showProgressIndicator()

    func showProgressMessage(_ message: String)

    func fetchCompleted()

    func fetchFailed(with: String)
}

final class PhotosVC: UIViewController {
    @IBOutlet private var collectionView: UICollectionView!

    private var album: AlbumsResponse.Album!

    private var refreshControl: UIRefreshControl!

    private var viewModel: PhotosVMProtocol!

    private var isRefreshFinishing = false

    private var progressView: PhotosProgressView!

    private var cellsInline: CGFloat {
        return UIDevice.current.orientation.isPortrait ? 4 : 5
    }

    private var cellSize: CGSize!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = PhotosVM(viewController: self, album: album)

        configureNavigationBar()
        configureRefreshControl()

        viewModel.fetch(isRefresh: false)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        configureCellSize()
    }

    private func configureNavigationBar() {
        navigationItem.title = album.title
    }

    private func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefreshControl(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    private func configureCellSize() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("Layout not inherit from UICollectionViewFlowLayout")
        }

        let layoutWidth = view.safeAreaLayoutGuide.layoutFrame.width
        let width = layoutWidth - layout.sectionInset.left - layout.sectionInset.right -
                    layout.minimumLineSpacing * (cellsInline - 1)
        let size = (width / cellsInline).rounded(.down)
        cellSize = CGSize(width: size, height: size)
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let photo = viewModel.photo(at: indexPath.row) else {
//            return
//        }
//
//        let viewController = DetailsVC.storyboardInstance()
//        viewController.setAlbum(album, indexPath: indexPath)
//        navigationController?.pushViewController(viewController, animated: true)
    }

    private func stopRefreshing() {
        guard refreshControl.isRefreshing else {
            return
        }

        if collectionView.isDragging {
            isRefreshFinishing = true
        } else {
            refreshControl.endRefreshing()
        }
    }
}

extension PhotosVC: PhotosVCProtocol {
    func setAlbum(_ album: AlbumsResponse.Album) {
        self.album = album
    }

    func showProgressIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.progressView.showIndicator()
        }
    }

    func showProgressMessage(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.progressView.showLabel(message)
        }
    }

    func fetchCompleted() {
        DispatchQueue.main.async { [weak self] in
            self?.stopRefreshing()
            self?.collectionView.safeReloadData()
        }
    }

    func fetchFailed(with error: String) {
        DispatchQueue.main.async { [weak self] in
            self?.stopRefreshing()
        }
    }
}

extension PhotosVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: PhotosProgressView.identifier,
                                                                   for: indexPath)
        progressView = view as? PhotosProgressView
        return progressView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard
            let cell = cell as? PhotosCell,
            let photo = viewModel.photo(at: indexPath.row) else {
                return
        }

        cell.configure(photo)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotosCell else {
            return
        }

        cell.didEndDisplaying()
    }
}

extension PhotosVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            return collectionView.dequeueReusableCell(withReuseIdentifier: PhotosCell.identifier,
                                                      for: indexPath)
    }
}
