//
//  DetailsViewController.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import Swinject

protocol DetailVCProtocol {
    var container: Container! { get set }

    var viewModel: PhotosVMProtocol! { get set }
}

final class DetailsVC: UIViewController {

    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var bottomView: UIView!
    @IBOutlet private var likesLabel: UILabel!
    @IBOutlet private var repostsLabel: UILabel!
    @IBOutlet private var commentsLabel: UILabel!

    var container: Container!

    var viewModel: PhotosVMProtocol!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        navigationController?.navigationBar.barStyle = .black
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureGestures()
        configureTitle()

        viewModel.fetch(isRefresh: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollToIndexPath()

        print(#function)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        collectionView.reloadData()
    }

    func configureGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        bottomView.isHidden.toggle()
        navigationController?.navigationBar.isHidden.toggle()
    }

    func configureTitle() {
        if viewModel.indexPath == nil {
            viewModel.indexPath = IndexPath(row: 0, section: 0)
        }

        if let cell = collectionView.visibleCells.first, let currentIndexPath = collectionView.indexPath(for: cell) {
            viewModel.indexPath = currentIndexPath
        }

        navigationItem.title = "\(viewModel.indexPath!.row + 1) of \(viewModel.total)"

        let photo = viewModel.photo(at: viewModel.indexPath!.row)!

        likesLabel.text = String(photo.likesCount)
        repostsLabel.text = String(photo.repostsCount)
        commentsLabel.text = String(photo.commentsCount)
    }

    func scrollToIndexPath() {
        guard let indexPath = viewModel.indexPath else {
            return
        }

        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
    }

    func fetchCompleted() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }

    func fetchFailed(with error: String) {
        //
    }
}

extension DetailsVC: DetailVCProtocol {
    func setup(_ viewModel: PhotosVMProtocol) {
        self.viewModel = viewModel
    }
}

extension DetailsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.bounds.size
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        configureTitle()

        guard let cell = cell as? DetailsCell, let photo = viewModel.photo(at: indexPath.row) else {
            return
        }

        cell.configure(container: container, photo: photo)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        configureTitle()

        guard let cell = cell as? DetailsCell else {
            return
        }

        cell.didEndDisplaying()
    }
}

extension DetailsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
                        -> UICollectionViewCell {
        configureTitle()
        return collectionView.dequeueReusableCell(withReuseIdentifier: DetailsCell.identifier, for: indexPath)
    }
}
