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
    
    // Current Date
    var current_date: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Starting Maps")
        map_view.delegate = self
        
        getDate()
        checkLocationServices()
    }
    
    func getDate() {
        // 1. Setup Date & Calendar
        let date = Date()
        let calendar = Calendar.current
        
        // 2. Get Date for Places API Request URLs
        let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: date)
        let year = components.year
        let day = components.day
        var check_month: String = ""
        
        // 3. Format month
        if let unwrapped_month = components.month {
            if unwrapped_month >= 1 && unwrapped_month <= 9 {
                check_month = "0\(unwrapped_month)"
            } else {
                check_month = "\(unwrapped_month)"
            }
        }
        
        // 4. Setup Current Date
        current_date = "\(year!)\(check_month)\(day!)"
    }
    
    func fetchData(latitude: Double, longitude: Double) {
        // 1. Use 'Search' request URL from Places API
        let search_url = "https://api.foursquare.com/v2/venues/search?ll=\(latitude),\(longitude)&categoryId=\(food_id)&radius=10000&client_id=\(client_id)&client_secret=\(client_secret)&v=\(current_date)"
        
        //  - Format URL
        guard let url = URL(string: search_url) else { return }
        
        // 2. Parses JSON from "Search for Venues" request
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {return}
//            let dataAsString = String(data: data, encoding: .utf8)
//            print (dataAsString)
            // - Read JSON -> Store in Dictionary
            if let json = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let unwrapped_response = json["response"] as? [String: Any] {
                    let venues_json: [[String: Any]] = unwrapped_response["venues"] as! [[String: Any]]
                    //  - Store:
                    //      Title
                    //      Address
                    //      Coordinate
                    var counter = 1
                    self.restaurants.removeAll()
                    for venue_json in venues_json {
                        if let venue = Restaurant.from(restaurant: venue_json) {
                            self.restaurants.append(venue)
                            print(counter)
                            counter += 1
                        }
                    }
                }
            }
            
            // 3. Add Annotations
            self.map_view.addAnnotations(self.restaurants)
            
            print("Restaurants: \(self.restaurants.count)")
            }.resume()
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
            print("Location Services Not enabled")
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
            // Makes "Search" request from Places API
            if let location = location_manager.location?.coordinate {
                print("------Fetching Data!------")
                fetchData(latitude: location.latitude, longitude: location.longitude)
                print("Lat: \(location.latitude), Lon: \(location.longitude)")
            }
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
        
        map_view.setRegion(region, animated: true)
    }
    
    
    // When user clicks allow, it immediately sets up the user's location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // When authorization changes
        checkLocationAuthorization()
    }
}

extension MapsViewController: MKMapViewDelegate {
    
    // Setting up the Annotation & Pin
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
