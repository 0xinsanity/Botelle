//
//  CreateNewListController.swift
//  Botelle
//
//  Created by Noah Hanover on 8/1/17.
//  Copyright © 2017 Botelle. All rights reserved.
//

import UIKit
import Material
import FirebaseDatabase
import PureLayout
import CoreLocation
import M13Checkbox

class CreateNewListController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    var nameField: TextField!
    var locationField: TextField!
    var createCommunity: RaisedButton!
    var locationCheckBox: M13Checkbox!
    var currentLocationLabel: UILabel!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navShadow()
        hideKeyboardWhenTappedAround()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        let background = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        background.backgroundColor = UIColor.white
        self.view.addSubview(background)
        
        let back = IconButton(image: Icon.cm.arrowBack)
        back.tintColor = teal
        back.addTarget(self, action: #selector(popBack), for: UIControlEvents.touchUpInside)
        navigationItem.leftViews = [back]
        self.navigationItem.backButton.isHidden = true
        
        nameField = TextField(frame: CGRect(x: 0, y: 0, width: self.view.frame.width*0.8, height: 40))
        nameField.placeholder = "Name of Community"
        nameField.placeholderActiveColor = teal
        nameField.dividerActiveColor = teal
        nameField.delegate = self
        self.view.addSubview(nameField)
        
        locationField = TextField(frame: CGRect(x: 0, y: 0, width: self.view.frame.width*0.8, height: 40))
        locationField.placeholder = "Location"
        locationField.placeholderActiveColor = teal
        locationField.dividerActiveColor = teal
        locationField.delegate = self
        self.view.addSubview(locationField)
        
        createCommunity = RaisedButton(frame: CGRect(x: 0 , y: 0, width: self.view.frame.width/2, height: 30))
        createCommunity.backgroundColor = teal
        createCommunity.setTitle("Create Account", for: UIControlState.normal)
        createCommunity.addTarget(self, action: #selector(createCommunityFunc), for: UIControlEvents.touchUpInside)
        createCommunity.layer.cornerRadius = 10
        createCommunity.titleLabel?.font = UIFont(name: "ProximaNova-Semibold", size: 17)
        createCommunity.pulseColor = UIColor.white
        view.layout(createCommunity).width(self.view.frame.width*0.8).height(50)
        self.view.addSubview(createCommunity)
        
        locationCheckBox = M13Checkbox(frame: CGRect(x: 45, y: 180, width: 25, height: 25))
        locationCheckBox.boxType = .square
        locationCheckBox.markType = .checkmark
        locationCheckBox.tintColor = teal
        locationCheckBox.stateChangeAnimation = .flat(.fill)
        //locationCheckBox.
        self.view.addSubview(locationCheckBox)
        
        currentLocationLabel = UILabel()
        currentLocationLabel.text = "Use Current Location"
        currentLocationLabel.font = UIFont(name: "ProximaNova-Regular", size: 15)
        self.view.addSubview(currentLocationLabel)
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            locationCheckBox.checkState = .checked
            currentLocationLabel.textColor = teal
            locationField.isUserInteractionEnabled = false
            locationField.text = "Current Location"
            locationField.textColor = .gray
            currentLocationLabel.textColor = teal
        } else {
            locationCheckBox.checkState = .unchecked
            currentLocationLabel.textColor = .gray
        }
        
        nameField.autoPinEdge(.top, to: .top, of: view, withOffset: 50, relation: NSLayoutRelation.equal)
        locationField.autoPinEdge(.top, to: .bottom, of: nameField, withOffset: 40, relation: NSLayoutRelation.equal)
        //locationCheckBox.autoPinEdge(.top, to: .bottom, of: locationField, withOffset: 30, relation: NSLayoutRelation.equal)
        currentLocationLabel.autoPinEdge(.top, to: .bottom, of: locationField, withOffset: 35, relation: NSLayoutRelation.equal)
        //locationCheckBox.autoPinEdge(toSuperviewEdge: .left, withInset: 45)
        currentLocationLabel.autoPinEdge(.left, to: .right, of: locationCheckBox, withOffset: 12, relation: NSLayoutRelation.equal)
        createCommunity.autoPinEdge(.top, to: .bottom, of: currentLocationLabel, withOffset: 30, relation: NSLayoutRelation.equal)
        nameField.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        locationField.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        createCommunity.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        
        view.addConstraint(NSLayoutConstraint(item: locationCheckBox, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: locationField, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 30))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "Create New List"
    }
    
    func popBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func checkBoxToggle() {
        switch locationCheckBox.checkState {
        case .checked:
            currentLocationLabel.textColor = teal
            locationField.isUserInteractionEnabled = false
            locationField.text = "Current Location"
            locationField.textColor = .gray
            currentLocationLabel.textColor = teal
            break
        default:
            locationCheckBox.checkState = .unchecked
            currentLocationLabel.textColor = .gray
            locationField.isUserInteractionEnabled = true
            locationField.text = ""
            locationField.textColor = .black
            break
        }
    }
    
    func createCommunityFunc() {
        print("hi")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField {
            if (locationField.isUserInteractionEnabled) {
                locationField.becomeFirstResponder()
            } else {
                createCommunityFunc()
                return true
            }
        } else if textField == locationField {
            createCommunityFunc()
            return true
        }
        return true
    }
    
}
