//
//  VKDelegate.swift
//  GalleryDemo
//
//  Created by roman on 01/04/2019.
//  Copyright © 2019 figma. All rights reserved.
//

import UIKit
import SwiftyVK

final class VKDelegate {
    
    let appId = "6921197"
    let scopes: Scopes = [.photos]
    
    init() {
        VK.setUp(appId: appId, delegate: self)
    }
}

extension VKDelegate: SwiftyVKDelegate {
    
    func vkNeedsScopes(for sessionId: String) -> Scopes {
        return scopes
    }
    
    func vkNeedToPresent(viewController: VKViewController) {
        guard let rootController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        
        rootController.present(viewController, animated: true)
    }
    
    func vkTokenCreated(for sessionId: String, info: [String : String]) {
        print("token created in session \(sessionId) with info \(info)")
    }
    
    func vkTokenUpdated(for sessionId: String, info: [String : String]) {
        print("token updated in session \(sessionId) with info \(info)")
    }
    
    func vkTokenRemoved(for sessionId: String) {
        print("token removed in session \(sessionId)")
    }
}
