//
//  DetailsViewController.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

protocol DetailsVCProtocol: AnyObject {
    func fetchCompleted()

    func fetchFailed(with: String)
}

final class DetailsVC: UIViewController {
    @IBOutlet private var collectionView: UICollectionView!

    private var viewModel: DetailsVMProtocol!

    private var album: AlbumsResponse.Album!

    private var selectedIndexPath: IndexPath!

    private var currentIndex: Int {
        if
            let cell = collectionView.visibleCells.first,
            let indexPath = collectionView.indexPath(for: cell) {
                return indexPath.row + 1
        }

        return 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = DetailsVM(viewController: self, album: album)
        viewModel.fetch(as: .load)

        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .centeredHorizontally)
    }

    func setAlbum(_ album: AlbumsResponse.Album, indexPath: IndexPath) {
        self.album = album
        selectedIndexPath = indexPath
    }

    func updateBarTitle() {
        navigationItem.title = "\(currentIndex) of \(viewModel.total)"
    }
}

extension DetailsVC: DetailsVCProtocol {
    func fetchCompleted() {
        DispatchQueue.main.async { [weak self] in
            self?.updateBarTitle()
            self?.collectionView.reloadData()
        }
    }

    func fetchFailed(with error: String) {
        //
    }
}

extension DetailsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.bounds.size
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let cell = cell as? DetailsCell else {
            return
        }

        if let photo = viewModel.photo(at: indexPath.row) {
            cell.configure(photo)
        }

        updateBarTitle()
        viewModel.prefetchIfNeeded(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? DetailsCell {
            cell.cancel()
        }

        updateBarTitle()
    }
}

extension DetailsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            return collectionView.dequeueReusableCell(withReuseIdentifier: DetailsCell.identifier,
                                                      for: indexPath)
    }
}
