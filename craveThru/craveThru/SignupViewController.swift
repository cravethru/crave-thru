//
//  SignupViewController.swift
//  craveThru
//
//  Created by Eros Gonzalez on 4/11/19.
//  Copyright © 2019 Eros Gonzalez. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //*Underlining text fields*
        emailField.underlined()
        passwordField.underlined()
        confirmPasswordField.underlined()
        
        //*changing placeholder text color to dark gray*
        emailField.attributedPlaceholder = NSAttributedString(string: "E-mail", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        confirmPasswordField.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSignup(_ sender: Any) {
        let emailText =  emailField.text!
        let passwordText = passwordField.text!
        let confirmPasswordText = confirmPasswordField.text!
        
        if passwordText == confirmPasswordText{
            Auth.auth().createUser(withEmail: emailText, password: passwordText) { authResult, error in
                if error != nil{
                    print ("Sign in error")
                }
                else{
                    let user = Auth.auth().currentUser
                    user?.sendEmailVerification(completion: nil)
                    
                    let alert = UIAlertController(title: "Crave-Thru", message: "A verification email has been sent to \(emailText). Please verify your email adress before loging in.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: {_ in self.performSegue(withIdentifier: "BackToLogin", sender: self)}))
                    
                    //alert.addAction(alertSegue)

                    self.present(alert, animated: true)
                }
            }
        }
    }
    @IBAction func onBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
