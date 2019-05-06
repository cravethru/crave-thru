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
