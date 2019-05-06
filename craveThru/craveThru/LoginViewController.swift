//
//  LoginViewController.swift
//  craveThru
//
//  Created by Angel on 4/8/19.
//  Copyright © 2019 Eros Gonzalez. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate{
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var verifyError: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //*Underlining text fields*
        emailField.underlined()
        passwordField.underlined()
        
        //*changing placeholder text color to dark gray*
        emailField.attributedPlaceholder = NSAttributedString(string: "E-mail", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
         passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }

    @IBAction func onLogin(_ sender: Any) {
       self.performSegue(withIdentifier: "LoginSegueue", sender: self)        // let emailText = emailField.text!
        let passwordText = passwordField.text!
        
        if emailText == "" && passwordText == ""{
            self.performSegue(withIdentifier: "LoginSegue", sender: self)
        }
        
        Auth.auth().signIn(withEmail: emailText, password: passwordText) {(user, error) in
            if error != nil{
                print (error!)
            }
            else if let user = Auth.auth().currentUser{
                if !user.isEmailVerified{
                    self.verifyError.textColor = UIColor.red
                }
                else{
                    self.verifyError.textColor = UIColor.white
                    self.performSegue(withIdentifier: "LoginSegue", sender: self)
                }
            }
        }

    }
    
    @IBAction func onSignup(_ sender: Any) {
        self.performSegue(withIdentifier: "SignupSegueue", sender: self)
    }
}

extension UITextField{
    func underlined(){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
