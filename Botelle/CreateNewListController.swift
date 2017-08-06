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
import Firebase
import PureLayout
import CoreLocation
import M13Checkbox

class CreateNewListController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    var nameField: TextField!
    var addMembersField: TextField!
    var locationField: TextField!
    var createCommunity: RaisedButton!
    var locationCheckBox: M13Checkbox!
    var currentLocationLabel: UILabel!
    var locationManager: CLLocationManager!
    var current_location: CLLocation!
    
    let ref = Database.database().reference()
    let user_email = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "_")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navShadow()
        hideKeyboardWhenTappedAround()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
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
        
        addMembersField = TextField(frame: CGRect(x: 0, y: 0, width: self.view.frame.width*0.8, height: 40))
        addMembersField.placeholder = "Add Members (Emails seperated by ,)"
        addMembersField.placeholderActiveColor = teal
        addMembersField.dividerActiveColor = teal
        addMembersField.delegate = self
        self.view.addSubview(addMembersField)
        
        locationField = TextField(frame: CGRect(x: 0, y: 0, width: self.view.frame.width*0.8, height: 40))
        locationField.placeholder = "Location"
        locationField.placeholderActiveColor = teal
        locationField.dividerActiveColor = teal
        locationField.delegate = self
        self.view.addSubview(locationField)
        
        createCommunity = RaisedButton(frame: CGRect(x: 0 , y: 0, width: self.view.frame.width/2, height: 30))
        createCommunity.backgroundColor = teal
        createCommunity.setTitle("Create New Community", for: UIControlState.normal)
        createCommunity.addTarget(self, action: #selector(createCommunityFunc), for: UIControlEvents.touchUpInside)
        createCommunity.layer.cornerRadius = 10
        createCommunity.titleLabel?.font = UIFont(name: "ProximaNova-Semibold", size: 17)
        createCommunity.pulseColor = UIColor.white
        view.layout(createCommunity).width(self.view.frame.width*0.8).height(50)
        self.view.addSubview(createCommunity)
        
        locationCheckBox = M13Checkbox(frame: CGRect(x: 45, y: 255, width: 25, height: 25))
        locationCheckBox.boxType = .square
        locationCheckBox.markType = .checkmark
        locationCheckBox.tintColor = teal
        locationCheckBox.stateChangeAnimation = .flat(.fill)
        locationCheckBox.addTarget(self, action: #selector(checkBoxToggle), for: UIControlEvents.valueChanged)
        self.view.addSubview(locationCheckBox)
        
        currentLocationLabel = UILabel()
        currentLocationLabel.text = "Use Current Location"
        currentLocationLabel.font = UIFont(name: "ProximaNova-Regular", size: 15)
        self.view.addSubview(currentLocationLabel)
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            locationManager.startUpdatingLocation()
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
        addMembersField.autoPinEdge(.top, to: .bottom, of: nameField, withOffset: 40, relation: NSLayoutRelation.equal)
        locationField.autoPinEdge(.top, to: .bottom, of: addMembersField, withOffset: 40, relation: NSLayoutRelation.equal)
        currentLocationLabel.autoPinEdge(.top, to: .bottom, of: locationField, withOffset: 35, relation: NSLayoutRelation.equal)
        currentLocationLabel.autoPinEdge(.left, to: .right, of: locationCheckBox, withOffset: 12, relation: NSLayoutRelation.equal)
        createCommunity.autoPinEdge(.top, to: .bottom, of: currentLocationLabel, withOffset: 30, relation: NSLayoutRelation.equal)
        nameField.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        addMembersField.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        locationField.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        createCommunity.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        
        view.addConstraint(NSLayoutConstraint(item: locationCheckBox, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: locationField, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 30))
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        current_location = locations.first
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
            if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways) {
                locationManager.requestAlwaysAuthorization()
            }
            locationManager.startUpdatingLocation()
            currentLocationLabel.textColor = teal
            locationField.isUserInteractionEnabled = false
            locationField.text = "Current Location"
            locationField.textColor = .gray
            currentLocationLabel.textColor = teal
            break
        default:
            locationManager.stopUpdatingLocation()
            locationCheckBox.checkState = .unchecked
            currentLocationLabel.textColor = .gray
            locationField.isUserInteractionEnabled = true
            locationField.text = ""
            locationField.textColor = .black
            break
        }
    }
    
    func createCommunityFunc() {
        if (locationField.text! == "" || nameField.text! == "" || nameField.text! == "My Location") {
            let alertView = UIAlertController(title: "Error", message: "Something went wrong with what you entered. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            alertView.addAction(okButton)
            self.present(alertView, animated: true, completion: nil)
            return
        }
        
        if (locationCheckBox.checkState == .checked) {
            let geo = CLGeocoder()
            
            var full_address = ""
            geo.reverseGeocodeLocation(current_location, completionHandler: { (placemarks, error) in
                let placemark = placemarks?[0]
                if ((placemark) != nil) {
                    full_address = (placemark?.addressDictionary?["FormattedAddressLines"] as! [String]).joined(separator: ", ")
                    let dictionary = ["address": full_address, "longitude": Double(self.current_location.coordinate.longitude), "latitude": Double(self.current_location.coordinate.latitude)] as [String : Any]
                    self.ref.child("Shopping List/\(self.nameField.text!)/area/").setValue(dictionary)
                    self.ref.child("Users").child(self.user_email).child("lists").setValue([self.nameField.text!])
                    self.ref.child("Shopping List/\(self.nameField.text!)/addMembers/").setValue(self.addMembersField.text!.components(separatedBy: ", "))
                    
                    self.navigationController?.present(NavigationController(rootViewController: ViewController()), animated: true, completion: nil)
                } else {
                    let alertView = UIAlertController(title: "Error", message: "We could not find your location. Please input it manually.", preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alertView.addAction(okButton)
                    self.present(alertView, animated: true, completion: nil)
                    return
                }
            })
        } else {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(locationField.text!, completionHandler: { (placemarks, error) in
                let placemark = placemarks?.first
                
                if (placemark?.location != nil) {
                    self.ref.child("Shopping List/\(self.nameField.text!)/area").setValue(["address": self.locationField.text!, "longitude": placemark?.location?.coordinate.longitude, "latitude": placemark?.location?.coordinate.latitude])
                } else {
                    let alertView = UIAlertController(title: "Error", message: "We could not find your location. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alertView.addAction(okButton)
                    self.present(alertView, animated: true, completion: nil)
                    return
                }
                self.ref.child("Users/\(self.user_email)").setValue(["lists": [self.nameField.text!]])
                self.ref.child("Shopping List/\(self.nameField.text!)/addMembers/").setValue(self.addMembersField.text!.components(separatedBy: ", "))
                
                self.navigationController?.present(NavigationController(rootViewController: ViewController()), animated: true, completion: nil)
                
            })
        }
        //ref.child("Shopping List/\(nameField.text!)/admin").setValue([Auth.auth().currentUser?.email])
        
        ref.child("Users/\(user_email)/full_name").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let value  = snapshot.value as? String
            self.ref.child("Shopping List/\(self.nameField.text!)/users/").setValue([value])
        })
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField {
            addMembersField.becomeFirstResponder()
            return true
        } else if textField == addMembersField {
            if (locationField.isUserInteractionEnabled) {
                locationField.becomeFirstResponder()
            } else {
                createCommunityFunc()
                return true
            }
        } else {
            createCommunityFunc()
            return true
        }
        return true
    }
    
}
