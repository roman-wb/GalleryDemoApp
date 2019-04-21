//
//  PhotosViewController.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

protocol PhotosVCProtocol: class {

    func showProgressIndicator()

    func showProgressLabel(text: String)

    func fetchCompleted()

    func fetchFailed(with: String)
}

final class PhotosVC: UIViewController {

    @IBOutlet private var collectionView: UICollectionView!

    private var refreshControl: UIRefreshControl!

    private var viewModel: PhotosVMProtocol!

    private var album: AlbumsResponse.Album!

    private var isRefreshFinishing = false

    private var progressView: PhotosProgressView!

    private var cellsInline: CGFloat {
        return UIDevice.current.orientation.isPortrait ? 4 : 5
    }

    private var cellSize: CGSize!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = PhotosVM(viewController: self, album: album)

        configureNavigationBar()
        configureRefreshControl()

        viewModel.fetch(as: .load)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureCellSize()
    }

    func setAlbum(_ album: AlbumsResponse.Album) {
        self.album = album
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
        if collectionView.isDragging {
            isRefreshFinishing = true
        } else {
            refreshControl.endRefreshing()
        }
    }
}

extension PhotosVC: PhotosVCProtocol {

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
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: PhotosProgressView.identifier,
                                                                   for: indexPath)
        progressView = cell as? PhotosProgressView
        return progressView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotosCell else {
            return
        }

        if let photo = viewModel.photo(at: indexPath.row) {
            cell.configure(photo)
        }

        viewModel.prefetchIfNeeded(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? PhotosCell {
            cell.cancel()
        }
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
