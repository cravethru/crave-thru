//
//  LoginViewController.swift
//  craveThru
//
//  Created by Angel on 4/8/19.
//  Copyright © 2019 Eros Gonzalez. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate{
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var verifyError: UILabel!
    
    let locationManager = CLLocationManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //*Underlining text fields*
        emailField.underlined()
        passwordField.underlined()
        
        //*changing placeholder text color to dark gray*
        emailField.attributedPlaceholder = NSAttributedString(string: "E-mail", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        checkLocationAuthorization()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        if CLLocationManager.locationServicesEnabled() {
//            switch CLLocationManager.authorizationStatus() {
//            case .notDetermined, .restricted, .denied:
//                locationManager.requestWhenInUseAuthorization()
//                locationForce()
//                break
//            case .authorizedAlways, .authorizedWhenInUse:
//                print("Access")
//                break
//            }
//        }else{
//            locationManager.requestWhenInUseAuthorization()
//            self.performSegue(withIdentifier: "LocationOffSegue", sender: self)
//            print ("segue")
//        }
//    }
//    func locationForce() -> Void{
//        if CLLocationManager.locationServicesEnabled() {
//            switch CLLocationManager.authorizationStatus() {
//            case .notDetermined, .restricted, .denied:
//                self.performSegue(withIdentifier: "LocationOffSegue", sender: self)
//                print ("segue")
//                break
//            case .authorizedAlways, .authorizedWhenInUse:
//                return
//            }
//        }
//    }
    
    @IBAction func onLogin(_ sender: Any) {
//        let emailText = emailField.text!
//        let passwordText = passwordField.text!
        
//        if emailText == "" && passwordText == ""{
//            self.performSegue(withIdentifier: "LoginSegue", sender: self)
//        }
        
        checkLocationAuthorization()
        
        let emailText = "egonzalez-lopez@csumb.edu"
        let passwordText = "test123"
        
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
    
    // 3. Only run app when user gives access to location
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
            case .denied, .restricted:
                performSegue(withIdentifier: "LocationOffSegue", sender: nil)
                break
            
            case .notDetermined:
                MapsViewController.location_manager.requestWhenInUseAuthorization()
                print("--Not determined--")
                break
            case .authorizedAlways, .authorizedWhenInUse:
                PlacesAPICaller.getDate()
                MapsViewController.requestRestaurants { (is_finished) in
                    if is_finished {
                        print("--Printing all Restaurants--\n")
                        let restaurants = PlacesAPICaller.all_restaurants
                        
                        var counter = 1
                        for item in restaurants {
                            print("\(counter)) \(String(describing: item.name))")
                            counter += 1
                        }
                    } else {
                        print("Couldn't get restaurants")
                    }
                }
                break
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
