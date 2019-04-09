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
    let region_in_meters: Double = 10000
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Starting Maps")
        
        checkLocationServices()
    }
    
    func setupLocationManager() {
        location_manager.delegate = self as? CLLocationManagerDelegate
        location_manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = location_manager.location?.coordinate {
            
            // Lat + Lon = How far we're zoomed in
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: region_in_meters, longitudinalMeters: region_in_meters)
            map_view.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            // Setup location manager
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:  // When App Open, Get located when in use
            // Do Map Stuff
            map_view.showsUserLocation = true // Puts blue dot on map
            centerViewOnUserLocation()
            break
        case .denied:               // Not allowed, denied once? Pop up won't show up
            // Show alert instructing them how to turn on permission
            break
        case .notDetermined:
            location_manager.requestWhenInUseAuthorization()
        case.restricted:            // User cannot change app status, Ex: Parent can restrict child's location
            // Show an alert letting them know
            break
        case.authorizedAlways:      // Location is always on when app not and in use
            break
        }
    }
}
//
//extension MapsViewController: CLLocationManagerDelegate {
//    // Do something when location updates
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        <#code#>
//    }
//    
//    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        <#code#>
//    }
//}
