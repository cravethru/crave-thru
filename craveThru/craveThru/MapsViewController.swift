//
//  MapsViewController.swift
//  craveThru
//
//  Created by Raymond Esteybar on 4/7/19.
//  Copyright © 2019 Eros Gonzalez. All rights reserved.
//

import UIKit
import MapKit       // Display Maps
import CoreLocation // Show/Update User Location

class MapsViewController: UIViewController {

    @IBOutlet weak var map_view: MKMapView!
    
    let location_manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Starting Maps")
        
        // 1. Latitude & Longitude of "Monterey"
        let location = CLLocationCoordinate2D(latitude: 36.600256, longitude: -121.8946388)
        
        // 2. How far the view is
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        map_view.setRegion(region, animated: true)
        
        // 3. Create Annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Monterey"
        annotation.subtitle = "California"
        map_view.addAnnotation(annotation)
    }
    
    func setupLocationManager() {
        location_manager.delegate = self
        location_manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            // Setup location manager
            setupLocationManager()
        } else {
            // Show alert letting the user know they have to turn this on
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            break
        case .denied:
            break
        case .notDetermined:
            break
        case.restricted:
            break
        case.authorizedAlways:
            break
        }
    }
}

extension MapsViewController: CLLocationManagerDelegate {
    // Do something when location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        <#code#>
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        <#code#>
    }
}
