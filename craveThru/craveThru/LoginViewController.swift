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
    @IBOutlet weak var signup: UIButton!
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        usernameField.underlined()
        passwordField.underlined()
        
        usernameField.attributedPlaceholder = NSAttributedString(string: "E-mail", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
         passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }

    @IBAction func onLogin(_ sender: Any) {
        let usernameString = usernameField.text!
        let passwordString = passwordField.text!
        
        Auth.auth().signIn(withEmail: usernameString, password: passwordString) {(user, error) in
            if error != nil{
                print (error!)
            }
            else{
                self.performSegue(withIdentifier: "LoginSegueue", sender: self)
            }
        }
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
