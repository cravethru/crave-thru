//
//  LocationOffViewController.swift
//  craveThru
//
//  Created by Eros Gonzalez on 5/4/19.
//  Copyright © 2019 Eros Gonzalez. All rights reserved.
//

import UIKit
import CoreLocation

class LocationOffViewController: UIViewController {
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    //let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var timer = Timer()
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                spinner.startAnimating()
                timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(stopLoadingSpinner), userInfo: nil, repeats: false)
                super.viewWillAppear(animated)
                
                // Denied: Not allowed, denied once? Pop up won't show up
                // Restricted: User cannot change app status, Ex: Parent restricts child's location
                //  - Show alert instructing them how to turn on permission
                let title = "Location Services Disabled"
                let message = "Please enable Location Services in Settings > CraveThru > Location > While Using the App."
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let settings_action = UIAlertAction(title: "Settings", style: .default) { (UIAlertAction) in
                    guard let settings_url = URL(string: UIApplication.openSettingsURLString) else { return }
                    
                    if UIApplication.shared.canOpenURL(settings_url) {
                        UIApplication.shared.open(settings_url, options: [:], completionHandler: nil)
                    }
                }
                
                alert.addAction(settings_action)
                present(alert, animated: true, completion: nil)
                
                break
            case .authorizedAlways, .authorizedWhenInUse:
                self.performSegue(withIdentifier: "LocationOnSegue", sender: self)
                print ("ALLOWED")
                break
            }
        }
    }
    
    @objc func stopLoadingSpinner() {
        spinner.stopAnimating()
        
        return
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
