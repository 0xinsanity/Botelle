//
//  CreateNewListController.swift
//  Botelle
//
//  Created by Noah Hanover on 8/1/17.
//  Copyright © 2017 Botelle. All rights reserved.
//

import UIKit
import Material

class CreateNewListController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let background = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        background.backgroundColor = UIColor.white
        self.view.addSubview(background)
        
        navigationController?.navigationBar.tintColor = teal
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "Create New List"
    }
    
    func popBack() {
        navigationController?.popViewController(animated: true)
    }
}
