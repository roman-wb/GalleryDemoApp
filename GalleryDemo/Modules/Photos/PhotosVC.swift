//
//  PhotosVC.swift
//  GalleryDemo
//
//  Created by roman on 16/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

protocol PhotosVCProtocol: class {

    func refreshing()

    func fetching()

    func fetchCompleted()

    func fetchFailed(with: String)
}

class PhotosVC: UIViewController {

    @IBOutlet private var collectionView: UICollectionView!
//    @IBOutlet private var headerView: UIView!
//    @IBOutlet private var footerView: UIView!

    private var refreshControl: UIRefreshControl!

    private var viewModel: PhotosVMProtocol!

    var album: Album!

    override func viewDidLoad() {
        super.viewDidLoad()

        print(album)

        let photo = Photo.new(id: 901, thumb: "asd")

        album.addToPhotos(photo)
//
        CoreDataManager.shared.saveContext()
//
//        viewModel = PhotosVM(album, viewController: self)

//        configureNavigationBar()
//        configureRefreshControl()
//        configureCollectionView()

//        viewModel.fetch(isRefresh: false)
    }

    func configureNavigationBar() {
        let label = UILabel(frame: .zero)
        label.text = album.title
        navigationItem.titleView = label
    }

    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        collectionView.refreshControl = refreshControl
    }

    func configureCollectionView() {
//        collectionView.tableHeaderView = nil
//        collectionView.tableFooterView = nil
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard refreshControl.isRefreshing else {
            return
        }
        viewModel.fetch(isRefresh: true)
    }
}

extension PhotosVC: PhotosVCProtocol {

    func refreshing() {
//        collectionView.tableHeaderView = nil
//        collectionView.tableFooterView = nil
    }

    func fetching() {
//        collectionView.tableHeaderView = nil
//        collectionView.tableFooterView = footerView
    }

    func fetchCompleted() {
        collectionView.reloadData()
        finished()
    }

    func fetchFailed(with error: String) {
        NotifyManager.shared.failure(error)
        finished()
    }

    private func finished() {
        if viewModel.count == 0 {
//            collectionView.tableHeaderView = headerView
        }
//        collectionView.tableFooterView = nil
        refreshControl.endRefreshing()
    }
}

extension PhotosVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {

//        if let cell = cell as? PhotosCell {
//            cell.cancel()
//        }

        viewModel.prefetch(by: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photosVC = PhotosVC.storyboardInstance()
        navigationController?.pushViewController(photosVC, animated: true)
    }
}

extension PhotosVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}
