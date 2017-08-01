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
    var loginButton: RaisedButton!
    var signupButton: UIButton!
    var logo: UIImageView!
    var welcomeBack: UILabel!
    var signintocontinue: UILabel!
    let teal = UIColor(rgb: 0x5A9B90)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeBack = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        welcomeBack.text = "Welcome Back,"
        welcomeBack.textAlignment = .center
        welcomeBack.font = UIFont.boldSystemFont(ofSize: 25)
        welcomeBack.opacity = 0
        self.view.addSubview(welcomeBack)
        
        signintocontinue = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        signintocontinue.text = "Sign in to continue"
        signintocontinue.textAlignment = .center
        signintocontinue.font = UIFont.systemFont(ofSize: 17)
        signintocontinue.textColor = UIColor.gray
        signintocontinue.opacity = 0
        self.view.addSubview(signintocontinue)
        
        emailField = TextField(frame: CGRect(x: 0, y: 140, width: self.view.frame.width*0.8, height: 40))
        emailField.placeholder = "Enter Email"
        if #available(iOS 10.0, *) {
            emailField.textContentType = UITextContentType.emailAddress
        }
        emailField.opacity = 0
        self.view.addSubview(emailField)
        
        passwordField = TextField(frame: CGRect(x: 0, y: 220, width: self.view.frame.width*0.8, height: 40))
        passwordField.placeholder = "Enter Password"
        passwordField.isSecureTextEntry = true
        passwordField.opacity = 0
        self.view.addSubview(passwordField)
        
        loginButton = RaisedButton(title: "Login", titleColor: UIColor.white)
        loginButton.backgroundColor = teal
        loginButton.opacity = 0
        loginButton.layer.cornerRadius = 10
        loginButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.width*0.8, height: 50)
        loginButton.addTarget(self, action: #selector(login), for: UIControlEvents.touchUpInside)
        self.view.addSubview(loginButton)
        
        signupButton = UIButton(frame: CGRect(x:self.view.frame.width/2 , y: 280, width: self.view.frame.width/2, height: 30))
        let signup_string = NSMutableAttributedString(string: "New user? Sign up")
        signup_string.addAttribute(NSForegroundColorAttributeName, value: teal, range: NSRange(location: 10, length: 7))
        signup_string.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 18), range: NSRange(location: 10, length: 7))
        signupButton.setAttributedTitle(signup_string, for: UIControlState.normal)
        signupButton.addTarget(self, action: #selector(signup), for: UIControlEvents.touchUpInside)
        signupButton.opacity = 0
        self.view.addSubview(signupButton)
        
        
        logo = UIImageView(image: UIImage(named: "logo.png"))
        logo.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        self.view.addSubview(logo)
        
        welcomeBack.autoPinEdge(.top, to: .bottom, of: logo, withOffset: -180, relation: NSLayoutRelation.equal)
        signintocontinue.autoPinEdge(.top, to: .bottom, of: welcomeBack, withOffset: 15, relation: NSLayoutRelation.equal)
        emailField.autoPinEdge(.top, to: .bottom, of: signintocontinue, withOffset: 45, relation: NSLayoutRelation.equal)
        passwordField.autoPinEdge(.top, to: .bottom, of: emailField, withOffset: 30, relation: NSLayoutRelation.equal)
        loginButton.autoPinEdge(.top, to: .bottom, of: passwordField, withOffset: 50, relation: NSLayoutRelation.equal)
        signupButton.autoPinEdge(.top, to: .bottom, of: loginButton, withOffset: 20, relation: NSLayoutRelation.equal)
        emailField.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        passwordField.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        loginButton.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        signupButton.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        welcomeBack.autoAlignAxis(toSuperviewAxis: .vertical)
        signintocontinue.autoAlignAxis(toSuperviewAxis: .vertical)
        
        logo.animate([MotionAnimation.position(CGPoint(x: logo.center.x, y: 130)), .duration(0.5)]) {
            self.emailField.animate(MotionAnimation.fadeIn)
            self.passwordField.animate(MotionAnimation.fadeIn)
            self.signupButton.animate(MotionAnimation.fadeIn)
            self.loginButton.animate(MotionAnimation.fadeIn)
            self.welcomeBack.animate(MotionAnimation.fadeIn)
            self.signintocontinue.animate(MotionAnimation.fadeIn)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func signup() {
        self.navigationController?.pushViewController(SignupViewController(), animated: true)
    }
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
