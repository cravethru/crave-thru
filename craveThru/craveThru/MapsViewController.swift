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

// Parse JSON
import Foundation

class MapsViewController: UIViewController {

    @IBOutlet weak var map_view: MKMapView!
    
    let location_manager = CLLocationManager()
    let region_in_meters: Double = 10000

    // Places API
    let client_id = "UH3KGN3HLTNDN1DIA1EIY0FKN120TC5W2L1H22EFPXMZFHJF"
    let client_secret = "OQ0F5RZWB53GZSWIKC4YWBTTJ4IDXQPPICLZQEUD3GQITVAA"
    let food_id = "4d4b7105d754a06374d81259"
    
    // All Restaurants around User Location
    var restaurants = [Restaurant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Starting Maps")
        
        checkLocationServices()
        
        // Example
        // To display annotations
        // Annotation View:
        //  - Title
        //  - Subtitle -> location_name
//        let sample_starbucks = Restaurant(title: "Starbucks Imagination", location_name: "Imagination Street", coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.431297))
//        map_view.addAnnotation(sample_starbucks)
        
        map_view.delegate = self
    }
    
    func fetchData(location: CLLocation) {
        let search_url = "https://api.foursquare.com/v2/venues/search?ll=\(location.coordinate.latitude),\(location.coordinate.longitude)&categoryId=\(food_id)&client_id=\(client_id)&client_secret=\(client_secret)&v=20190421"
        
        guard let search_request = URL(string: search_url) else { return }
        
        // Parses JSON from "Search for Venues" request
        URLSession.shared.dataTask(with: search_request) { (data, response, err) in
            guard let data = data else {return}
            
            // - Read JSON -> Store in Dictionary
            if let json = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let unwrapped_response = json["response"] as? [String: Any] {
                    let venues_json: [[String: Any]] = unwrapped_response["venues"] as! [[String: Any]]
                    
                    for venue_json in venues_json {
                        if let venue = Restaurant.from(restaurant: venue_json) {
                            self.restaurants.append(venue)
                        }
                    }
                }
            }
            }.resume()
        
        //        let restaurant_id = "428a8580f964a52083231fe3"
        //        let menu_url = "https://api.foursquare.com/v2/venues/\(restaurant_id)/menu?client_id=\(client_id)&client_secret=\(client_secret)&v=20190421"
    }
    
    func setupLocationManager() {
        location_manager.delegate = self as CLLocationManagerDelegate
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
    
    // Only run app when user gives access to location
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:                                      // When App Open, Get located when in use
            // Do Map Stuff
            map_view.showsUserLocation = true                           // Puts blue dot on map (User Location)
            centerViewOnUserLocation()
            location_manager.startUpdatingLocation()                    // Calls Delegate method
            break
        case .denied:                                                   // Not allowed, denied once? Pop up won't show up
            // Show alert instructing them how to turn on permission
            break
        case .notDetermined:
            location_manager.requestWhenInUseAuthorization()
        case.restricted:                                                // User cannot change app status, Ex: Parent restricts child's location
            // Show an alert letting them know
            break
        case.authorizedAlways:                                          // Location is always on when app not and in use
            break
        }
    }
}

extension MapsViewController: CLLocationManagerDelegate {
    // Do something when location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return } // if nil, do nothing
        
        // Makes the zoom in stay the position as the user moves
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: region_in_meters, longitudinalMeters: region_in_meters)
        
        // Makes "Search" request from Places API
        fetchData(location: location)
        map_view.addAnnotations(restaurants)
        print("-----Restaurant count: \(restaurants.count)-----")
        
        map_view.setRegion(region, animated: true)
    }
    
    
    // When user clicks allow, it immediately sets up the user's location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // When authorization changes
        checkLocationAuthorization()
    }
}

extension MapsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Restaurant {
            let identifier = "pin"
            var view: MKPinAnnotationView
            
            // Pinning
            //  - if   -> Already Created the view? Reuse Annotation View
            //  - else -> Create a new Annotation View
            if let dequeued_view = map_view.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeued_view.annotation = annotation
                view = dequeued_view
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true  // Decides to show (or not) the window
                view.animatesDrop = true    // Shows pin dropping from the top of screen
                view.calloutOffset = CGPoint(x: -5, y: 5)   // Where to place bubble
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView    // i button -> More info
            }
            
            return view
        }
        
        return nil
    }
}
