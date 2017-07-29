//
//  ListFormController.swift
//  Botelle
//
//  Created by Noah Hanover on 7/28/17.
//  Copyright © 2017 Botelle. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import Firebase

class ListFormController: UIViewController {
    var locationField: UITextField!
    var communityNameField: UITextField!
    var createListButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationField = UITextField(frame: CGRect(x: 0, y: 140, width: self.view.frame.width, height: 40))
        locationField.placeholder = "Enter Location (Zip Code)"
        self.view.addSubview(locationField)
        
        communityNameField = UITextField(frame: CGRect(x: 0, y: 190, width: self.view.frame.width, height: 40))
        communityNameField.placeholder = "Enter Community Name"
        self.view.addSubview(communityNameField)
        
        createListButton = UIButton(frame: CGRect(x:0 , y: 250, width: self.view.frame.width/2, height: 30))
        createListButton.backgroundColor = UIColor.blue
        createListButton.setTitle("Create List", for: UIControlState.normal)
        createListButton.addTarget(self, action: #selector(createList), for: UIControlEvents.touchUpInside)
        self.view.addSubview(createListButton)
    }
    
    func createList() {
        if (locationField.text! == "" || communityNameField.text! == "") {
            // TODO: Alert User
            return
        }
        
        let ref = Database.database().reference()
        let user_email = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "_")
        ref.child("Shopping List/\(communityNameField.text!)/area").setValue(locationField.text!)
        ref.child("Shopping List/\(communityNameField.text!)/users").setValue([Auth.auth().currentUser?.email])
        ref.child("Users/\(user_email)/list/").setValue(communityNameField.text!)
        
        self.present(UINavigationController(rootViewController: ViewController()), animated: true, completion: nil)
        //self.navigationController?.popViewController(animated: true)
    }
}
