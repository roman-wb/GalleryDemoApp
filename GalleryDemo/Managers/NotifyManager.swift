//
//  ToastNotification.swift
//  GalleryDemo
//
//  Created by roman on 02/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit

final class NotifyManager {

    static let shared = NotifyManager()

    private(set) var isHidden = true

    private init() { }

    func failure(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.factory(message, textColor: .white, backgroundColor: .red)
        }
    }

    private func factory(_ message: String, textColor: UIColor, backgroundColor: UIColor) {
        guard isHidden else {
            return
        }

        isHidden = false

        let superview = RouterVC.shared.currentViewController.view!

        let top = UIApplication.shared.keyWindow!.safeAreaInsets.top
        let width = superview.bounds.width
        let height = top + 44

        let frame = CGRect(x: 0, y: -height, width: width, height: height)
        let view = UIView(frame: frame)
        view.backgroundColor = backgroundColor

        let label = UILabel(frame: .zero)
        label.text = message
        label.textColor = textColor
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 20)
        view.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: top).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        superview.addSubview(view)

        show(view, height: height, duration: 1, delay: 3)
    }

    private func show(_ view: UIView, height: CGFloat, duration: TimeInterval, delay: TimeInterval) {
        UIView.animate(withDuration: duration, animations: {
            view.frame.origin.y = 0
        }, completion: { [weak self]  _ in
            self?.hide(view, height: height, duration: duration, delay: delay)
        })
    }

    private func hide(_ view: UIView, height: CGFloat, duration: TimeInterval, delay: TimeInterval) {
        UIView.animate(withDuration: duration, delay: delay, options: [], animations: {
            view.frame.origin.y = -height
        }, completion: { [weak self] _ in
            self?.isHidden = true
            view.removeFromSuperview()
        })
    }
}
