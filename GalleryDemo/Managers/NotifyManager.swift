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
    
    private init() { }
    
    func failure(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.factory(message, textColor: .white, backgroundColor: .red)
        }
    }
    
    func factory(_ message: String, textColor: UIColor, backgroundColor: UIColor) {
        let view = superview()
        let label = UILabel(frame: frame(for: view))
        label.text = message
        label.textColor = textColor
        label.backgroundColor = backgroundColor
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 16)
        view.addSubview(label)
        
        animation(label, height: 25, duration: 1, delay: 3)
    }
    
    private func animation(_ label: UILabel, height: CGFloat, duration: TimeInterval, delay: TimeInterval) {
        UIView.animate(withDuration: duration, animations: {
            label.frame.size.height = height
        }) { (finished) in
            UIView.animate(withDuration: duration, delay: delay, options: [], animations: {
                label.frame.size.height = 0
            }) { (finished) in
                label.removeFromSuperview()
            }
        }
    }
    
    private func superview() -> UIView {
        let viewController = RouterVC.shared.currentViewController!
        if let viewController = viewController as? UINavigationController {
            return viewController.navigationBar
        } else {
            return viewController.view
        }
    }
    
    private func frame(for view: UIView) -> CGRect {
        switch view {
        case is UINavigationBar:
            return CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: 0)
        default:
            return CGRect(x: 0, y: 0, width: view.bounds.width, height: 0)
        }
    }
}
