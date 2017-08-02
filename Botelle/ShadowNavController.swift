//
//  ShadowNavController.swift
//  Botelle
//
//  Created by Noah Hanover on 8/1/17.
//  Copyright © 2017 Botelle. All rights reserved.
//

import UIKit
import Material

class AppNavigationController: NavigationController {
    open override func prepare() {
        super.prepare()
        guard let v = navigationBar as? NavigationBar else {
            return
        }
        
        v.depthPreset = .none
        v.dividerColor = Color.grey.lighten3
    }
}
