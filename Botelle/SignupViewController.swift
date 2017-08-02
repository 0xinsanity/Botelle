//
//  SignupViewController.swift
//  Botelle
//
//  Created by Noah Hanover on 7/28/17.
//  Copyright © 2017 Botelle. All rights reserved.
//

import Foundation
import Firebase
import UIKit
import Material
import PureLayout
import CoreLocation

class SignupViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    var nameField: TextField!
    var emailField: TextField!
    var passwordField: TextField!
    var repeatPasswordField: TextField!
    var locationField: TextField!
    var createAccountButton: RaisedButton!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navShadow()
        hideKeyboardWhenTappedAround()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        let background_color = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        background_color.backgroundColor = UIColor.white
        self.view.addSubview(background_color)
        
        self.navigationController?.navigationBar.topItem?.title = "Sign Up"
        let back = IconButton(image: Icon.cm.arrowBack)
        back.tintColor = teal
        back.addTarget(self, action: #selector(backToLogin), for: UIControlEvents.touchUpInside)
        navigationItem.leftViews = [back]
 
        nameField = TextField(frame: CGRect(x: 0, y: 140, width: self.view.frame.width*0.8, height: 40))
        nameField.placeholder = "Full Name"
        nameField.placeholderActiveColor = teal
        nameField.dividerActiveColor = teal
        nameField.delegate = self
        self.view.addSubview(nameField)
        
        emailField = TextField(frame: CGRect(x: 0, y: 140, width: self.view.frame.width*0.8, height: 40))
        emailField.placeholder = "Email"
        emailField.placeholderActiveColor = teal
        emailField.dividerActiveColor = teal
        emailField.delegate = self
        if #available(iOS 10.0, *) {
            emailField.textContentType = UITextContentType.emailAddress
        }
        self.view.addSubview(emailField)
        
        passwordField = TextField(frame: CGRect(x: 0, y: 190, width: self.view.frame.width*0.8, height: 40))
        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        passwordField.placeholderActiveColor = teal
        passwordField.dividerActiveColor = teal
        passwordField.delegate = self
        self.view.addSubview(passwordField)
        
        repeatPasswordField = TextField(frame: CGRect(x: 0, y: 240, width: self.view.frame.width*0.8, height: 40))
        repeatPasswordField.placeholder = "Confirm Password"
        repeatPasswordField.isSecureTextEntry = true
        repeatPasswordField.placeholderActiveColor = teal
        repeatPasswordField.dividerActiveColor = teal
        repeatPasswordField.delegate = self
        self.view.addSubview(repeatPasswordField)
        
        locationField = TextField(frame: CGRect(x: 0, y: 140, width: self.view.frame.width*0.8, height: 40))
        locationField.placeholder = "Location (Address)"
        locationField.placeholderActiveColor = teal
        locationField.dividerActiveColor = teal
        locationField.delegate = self
        locationField.addTarget(self, action: #selector(getLocation), for: UIControlEvents.allTouchEvents)
        self.view.addSubview(locationField)
        
        createAccountButton = RaisedButton(frame: CGRect(x:200 , y: 290, width: self.view.frame.width/2, height: 30))
        createAccountButton.backgroundColor = teal
        createAccountButton.setTitle("Create Account", for: UIControlState.normal)
        createAccountButton.addTarget(self, action: #selector(createAccount), for: UIControlEvents.touchUpInside)
        createAccountButton.layer.cornerRadius = 10
        createAccountButton.titleLabel?.font = UIFont(name: "ProximaNova-Semibold", size: 17)
        createAccountButton.pulseColor = UIColor.white
        view.layout(createAccountButton).width(self.view.frame.width*0.8).height(50)
        self.view.addSubview(createAccountButton)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameField.autoPinEdge(.top, to: .top, of: view, withOffset: 100, relation: NSLayoutRelation.equal)
        emailField.autoPinEdge(.top, to: .bottom, of: nameField, withOffset: 40, relation: NSLayoutRelation.equal)
        passwordField.autoPinEdge(.top, to: .bottom, of: emailField, withOffset: 40, relation: NSLayoutRelation.equal)
        repeatPasswordField.autoPinEdge(.top, to: .bottom, of: passwordField, withOffset: 40, relation: NSLayoutRelation.equal)
        locationField.autoPinEdge(.top, to: .bottom, of: repeatPasswordField, withOffset: 40, relation: NSLayoutRelation.equal)
        createAccountButton.autoPinEdge(.top, to: .bottom, of: locationField, withOffset: 40, relation: NSLayoutRelation.equal)
        nameField.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        emailField.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        passwordField.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        repeatPasswordField.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        locationField.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        createAccountButton.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
    }
    
    func createAccount() {
        if (passwordField.text! == repeatPasswordField.text! && passwordField.text != "" && nameField.text != "" && emailField.text! != "" && locationField.text! != "") {
            let address_location = CLLocation(latitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!)
            let geo = CLGeocoder()
            
            var full_address = ""
            geo.reverseGeocodeLocation(address_location, completionHandler: { (placemarks, error) in
                let placemark = placemarks?[0]
                if ((placemark) != nil) {
                    full_address = (placemark?.addressDictionary?["FormattedAddressLines"] as! [String]).joined(separator: ", ")
                } else {
                    let alertView = UIAlertController(title: "Error", message: "We could not find your location. Please input it manually.", preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alertView.addAction(okButton)
                    self.present(alertView, animated: true, completion: nil)
                    return
                }
            })
            
            let email_text = emailField.text!.trimmingCharacters(in: .whitespaces).lowercased()
            let email_no_period = emailField.text!.replacingOccurrences(of: ".", with: "_").lowercased()
            Auth.auth().createUser(withEmail: email_text, password: passwordField.text!) { (user, error) in
                if error == nil {
                    // Move on
                    
                    let ref = Database.database().reference()
                    ref.child("Users/\(email_no_period)/full_name/").setValue(self.nameField.text)
                    
                    if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
                        ref.child("Users/\(email_no_period)/location/").setValue(full_address)
                    } else {
                        ref.child("Users/\(email_no_period)/location/").setValue(self.locationField.text)
                    }
                
                    self.navigationController?.present(NavigationController(rootViewController: FindListController()), animated: true, completion: nil)
                    
                } else {
                    var error_message: String = ""
                    if let errCode = AuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        case .invalidEmail:
                            error_message = "Your email or password was invalid."
                        case .emailAlreadyInUse:
                            error_message = "Your email is already in use."
                        case .userNotFound:
                            error_message = "Could not find the user."
                        default:
                            error_message = "There was a problem logging in."
                        }
                    }
                    
                    let alertView = UIAlertController(title: "Error", message: error_message, preferredStyle: UIAlertControllerStyle.alert)
                    let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alertView.addAction(okButton)
                    self.present(alertView, animated: true, completion: nil)
                }
            }
            
            
        } else {
            let alertView = UIAlertController(title: "Error", message: "Your Passwords Don't Match", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            alertView.addAction(okButton)
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    func backToLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    func getLocation() {
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways) {
            locationManager.requestAlwaysAuthorization()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            locationField.text = "Current Location"
            locationField.resignFirstResponder()
            locationField.isUserInteractionEnabled = false
            locationField.textColor = .gray
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            
            locationManager.startUpdatingLocation()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField {
            emailField.becomeFirstResponder()
            return false
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
            return false
        } else if textField == passwordField {
            repeatPasswordField.becomeFirstResponder()
            return false
        } else if textField == repeatPasswordField {
            if (!locationField.isUserInteractionEnabled) {
                textField.resignFirstResponder()
                createAccount()
            } else {
                locationField.becomeFirstResponder()
            }
            getLocation()
            return false
        } else {
            createAccount()
        }
        return true
    }
}

extension UIViewController {
    func navShadow() {
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 4.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1.0
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }
}
