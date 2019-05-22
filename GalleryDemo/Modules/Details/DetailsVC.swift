//
//  DetailsViewController.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import Swinject
import SwiftyVK

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
    @IBOutlet private var profileLabel: UILabel!
    @IBOutlet private var avatarImageView: WebImageView!

    var container: Container!
    var viewModel: PhotosVMProtocol!

    private var statusBarHidden = false

    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        configureNavigationBar()
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureGestures()
        configureFields()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollToIndexPath()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        collectionView.reloadData()
    }

    func configureNavigationBar() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = false

        let shareVKButton = UIBarButtonItem(image: UIImage(named: "vk"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(tapShareVKButton(_:)))
        let shareButton = UIBarButtonItem(image: UIImage(named: "share"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(tapShareButton(_:)))
        let locationButton = UIBarButtonItem(image: UIImage(named: "map"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(tapLocationButton(_:)))
        navigationItem.rightBarButtonItems = [locationButton, shareButton, shareVKButton]
    }

    func configureGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleBars(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func tapShareVKButton(_ sender: UIBarButtonItem) {
        guard
            let photo = viewModel.photo(at: viewModel.indexPath.row),
            let imageURL = photo.imageURL,
            let image = WebImageView.cache.object(forKey: imageURL.relativeString as NSString),
            let data = image.jpegData(compressionQuality: 1) else {
                return
        }

        VK.sessions.default.share(
            ShareContext(
                text: viewModel.fullnameBy(photo),
                images: [
                    ShareImage(data: data, type: .jpg)
                ]
            ),
            onSuccess: { print($0) },
            onError: { print($0) }
        )
    }

    @objc func tapShareButton(_ sender: UIBarButtonItem) {
        guard
            let photo = viewModel.photo(at: viewModel.indexPath.row),
            let imageURL = photo.imageURL else {
                return
        }

        let activityController = UIActivityViewController(activityItems: [imageURL], applicationActivities: nil)
        if let popoverController = activityController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: 0, width: 0, height: 0)
        }
        present(activityController, animated: true)
    }

    @objc func tapLocationButton(_ sender: UIBarButtonItem) {
        guard
            let photo = viewModel.photo(at: viewModel.indexPath.row),
            let imageURL = photo.imageURL,
            let location = photo.location else {
                return
        }

        let mapVC = container.resolve(MapVC.self)!
        mapVC.setup(fullName: viewModel.fullnameBy(photo),
                    imageURL: imageURL,
                    location: location)
        navigationController?.pushViewController(mapVC, animated: true)
    }

    func updateIndexPath() {
        viewModel.indexPath.row = Int(collectionView.contentOffset.x / collectionView.frame.width)
    }

    func configureFields() {
        let photo = viewModel.photo(at: viewModel.indexPath.row)!

        navigationItem.title = "\(viewModel.currentIndex) of \(viewModel.total)"

        likesLabel.text = String(photo.likesCount)
        repostsLabel.text = String(photo.repostsCount)
        commentsLabel.text = String(photo.commentsCount)
        profileLabel.text = viewModel.fullnameBy(photo)

        let avatarURL = viewModel.avatarURLBy(photo)
        avatarImageView.setImage(url: avatarURL)
    }

    @objc func toggleBars(_ gesture: UITapGestureRecognizer) {
        statusBarHidden.toggle()
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.navigationBar.isHidden = statusBarHidden
        bottomView.isHidden = statusBarHidden
    }

    func scrollToIndexPath() {
        guard let indexPath = viewModel.indexPath else {
            return
        }

        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        configureFields()
    }

    func fetchCompleted() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }

    func fetchFailed(with error: String) {
        //
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateIndexPath()
        configureFields()
    }
}

extension DetailsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.bounds.size
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard
            let cell = cell as? DetailsCell,
            let photo = viewModel.photo(at: indexPath.row) else {
                return
        }

        cell.configure(container: container, photo: photo)
    }
}

extension DetailsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
                        -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: DetailsCell.identifier, for: indexPath)
    }
}
