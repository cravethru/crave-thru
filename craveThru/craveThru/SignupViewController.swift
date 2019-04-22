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
    var db: Firestore!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
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
                    
                    if let addUser = user {
                        let uid = addUser.uid
                        let date = addUser.metadata.creationDate
                        
                        //Adding sign up information to database
                        self.addUserToDatabase(uid: uid, email: emailText, createdDate: date)
                    }
                    
                    
                    let alert = UIAlertController(title: "Crave-Thru", message: "A verification email has been sent to \(emailText). Please verify your email adress before loging in.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: {_ in self.performSegue(withIdentifier: "BackToLogin", sender: self)}))

                    self.present(alert, animated: true)
                }
            }
        }
    }
    @IBAction func onBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //Adding sign up information to database
    func addUserToDatabase(uid: String, email: String, createdDate: Date?) -> Void{
        let dateString = timestampToString(date: createdDate!)
        
        db.collection("users").document(uid).setData([
            "creationDate": dateString,
            "username": email.prefix(5),
            "numCities": 0
        ]) {err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(uid)")
            }
        }
    }
    
    //converts Date data type to string 
    func timestampToString(date: Date) -> String{
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM/dd/yy"
        
        let dateString = dateformatter.string(from: date)
        
        return dateString
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
