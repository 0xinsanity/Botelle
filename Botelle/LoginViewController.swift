//
//  File.swift
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

class LoginViewController: UIViewController {
    var emailField: TextField!
    var passwordField: TextField!
    var loginButton: UIButton!
    var signupButton: UIButton!
    var logo: UIImageView!
    var text_logo_placeholder: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        emailField = TextField(frame: CGRect(x: 0, y: 140, width: self.view.frame.width, height: 40))
        emailField.placeholder = "Enter Email"
        if #available(iOS 10.0, *) {
            emailField.textContentType = UITextContentType.emailAddress
        }
        emailField.opacity = 0
        self.view.addSubview(emailField)
        
        passwordField = TextField(frame: CGRect(x: 0, y: 220, width: self.view.frame.width, height: 40))
        passwordField.placeholder = "Enter Password"
        passwordField.isSecureTextEntry = true
        passwordField.opacity = 0
        self.view.addSubview(passwordField)
        
        loginButton = FlatButton(frame: CGRect(x:0 , y: 280, width: self.view.frame.width/2, height: 30))
        loginButton.backgroundColor = UIColor.blue
        loginButton.setTitle("Login", for: UIControlState.normal)
        loginButton.opacity = 0
        loginButton.addTarget(self, action: #selector(login), for: UIControlEvents.touchUpInside)
        self.view.addSubview(loginButton)
        
        signupButton = FlatButton(frame: CGRect(x:self.view.frame.width/2 , y: 280, width: self.view.frame.width/2, height: 30))
        signupButton.backgroundColor = UIColor.blue
        signupButton.setTitle("Signup", for: UIControlState.normal)
        signupButton.addTarget(self, action: #selector(signup), for: UIControlEvents.touchUpInside)
        signupButton.opacity = 0
        self.view.addSubview(signupButton)
        
        
        logo = UIImageView(image: UIImage(named: "logo.png"))
        self.view.addSubview(logo)
        
        text_logo_placeholder = UIImageView(image: UIImage(named: "text.png"))
        text_logo_placeholder.isHidden = true
        self.view.addSubview(text_logo_placeholder)
        
        text_logo_placeholder.autoCenterInSuperview()
        logo.autoPinEdge(ALEdge.bottom, to: ALEdge.top, of: text_logo_placeholder)
        logo.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.logo.removeFromSuperview()
            self.view.addSubview(self.logo)
            self.logo.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
            self.logo.autoPinEdge(toSuperviewMargin: ALEdge.top)
        }) { (bool) in
            self.emailField.animate(MotionAnimation.fadeIn)
            self.passwordField.animate(MotionAnimation.fadeIn)
            self.signupButton.animate(MotionAnimation.fadeIn)
            self.loginButton.animate(MotionAnimation.fadeIn)
        }
        
    }
    
    func login() {
        Auth.auth().signIn(withEmail: emailField.text!.trimmingCharacters(in: .whitespaces), password: passwordField.text!) { (user, error) in
            // ...
            if error == nil {
               // Move on
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
    }
    
    func signup() {
        self.navigationController?.pushViewController(SignupViewController(), animated: true)
    }
    
}
