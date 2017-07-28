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

class LoginViewController: UIViewController {
    var emailField: UITextField!
    var passwordField: UITextField!
    var loginButton: UIButton!
    var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login Page"
        
        emailField = UITextField(frame: CGRect(x: 0, y: 140, width: self.view.frame.width, height: 40))
        emailField.placeholder = "Enter Email"
        if #available(iOS 10.0, *) {
            emailField.textContentType = UITextContentType.emailAddress
        }
        self.view.addSubview(emailField)
        
        passwordField = UITextField(frame: CGRect(x: 0, y: 190, width: self.view.frame.width, height: 40))
        passwordField.placeholder = "Enter Password"
        passwordField.isSecureTextEntry = true
        self.view.addSubview(passwordField)
        
        loginButton = UIButton(frame: CGRect(x:0 , y: 250, width: self.view.frame.width/2, height: 30))
        loginButton.backgroundColor = UIColor.blue
        loginButton.setTitle("Login", for: UIControlState.normal)
        loginButton.addTarget(self, action: #selector(login), for: UIControlEvents.touchUpInside)
        self.view.addSubview(loginButton)
        
        signupButton = UIButton(frame: CGRect(x:self.view.frame.width/2 , y: 250, width: self.view.frame.width/2, height: 30))
        signupButton.backgroundColor = UIColor.blue
        signupButton.setTitle("Signup", for: UIControlState.normal)
        signupButton.addTarget(self, action: #selector(signup), for: UIControlEvents.touchUpInside)
        self.view.addSubview(signupButton)
        
    }
    
    func login() {
        Auth.auth().signIn(withEmail: emailField.text!.trimmingCharacters(in: .whitespaces), password: passwordField.text!) { (user, error) in
            // ...
            if error == nil {
               // Move on
                self.navigationController?.present(UINavigationController(rootViewController: FindListController()), animated: true, completion: nil)
                
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
