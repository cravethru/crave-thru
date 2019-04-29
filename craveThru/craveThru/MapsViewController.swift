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

class MapsViewController: UIViewController, UISearchBarDelegate {

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
        
        getDate()
        checkLocationServices()
    }
    
    // Searches a Location
    //  - Displays Search Bar
    @IBAction func searchButton(_ sender: Any) {
        let search_controller = UISearchController(searchResultsController: nil)
        search_controller.searchBar.delegate = self
        present(search_controller, animated: true, completion: nil)
    }
    
    //  - When user clicks on "Search" in Keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Ignore User
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Activity Indicator
        //  - Show's "loading" progress
        let activity_indicator = UIActivityIndicatorView()
        activity_indicator.style = UIActivityIndicatorView.Style.gray
        activity_indicator.center = self.view.center // Center indicator in middle of screen
        activity_indicator.hidesWhenStopped = true
        activity_indicator.startAnimating()
        
        self.view.addSubview(activity_indicator)
        
        // Hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        // Create search request
        let search_request = MKLocalSearch.Request()
        search_request.naturalLanguageQuery = searchBar.text
        
        let search = MKLocalSearch(request: search_request)
        search.start { (response, error) in
            guard let response = response else { return }
            
            activity_indicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            // Remove annotations (pins)
            let annotations = self.map_view.annotations
            self.map_view.removeAnnotations(annotations)
            
            // Get Location Data
            let latitude = response.boundingRegion.center.latitude
            let longitude = response.boundingRegion.center.longitude
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            // Zoom in on annotation
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // How much we want to be zoomed in at that coordinate
            let region = MKCoordinateRegion(center: coordinate, span: span)
            
            self.map_view.region = region
            
            // Create Annotations
            //  - Show restaurants
            self.populateNearByPlaces()
        }
    }
    
    
    // Option 1: Places API
    //  - Requires current date in URL
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
    
    //  - Retrieves JSON data
    func fetchData(latitude: Double, longitude: Double) {
        // 1. Use 'Search' request URL from Places API
        let search_url = "https://api.foursquare.com/v2/venues/search?categoryId=\(food_id)&client_id=\(client_id)&client_secret=\(client_secret)&v=\(current_date)"
        
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
            
            // 3. Show pins on screen
            self.map_view.addAnnotations(self.restaurants)
            
            print("Restaurants: \(self.restaurants.count)")
            }.resume()
    }
    
    // Option 2: Use Apple's Local Search for Restaurants
    func populateNearByPlaces() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Restaurants"
        request.region = self.map_view.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            
//            print("Total Restaurants Found: \(response.mapItems.count)")
//            print(response.mapItems)
            
            // Create Annotations / Pins on Map
            for item in response.mapItems {
                let annotation = MKPointAnnotation()
                
                // Store ea. restaurant's info
                annotation.title = item.name
                annotation.coordinate = item.placemark.coordinate
                
                DispatchQueue.main.async {
                    self.map_view.addAnnotation(annotation)
                }
            }
        }
    }
    
    // Initialize
    //  1. Check if User Enabled Location
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
    
    //  2. Set up for User Location
    func setupLocationManager() {
        location_manager.delegate = self as CLLocationManagerDelegate
        location_manager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        location_manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func setupMapView() {
        map_view.delegate = self
        map_view.showsUserLocation = true                           // Puts blue dot on map (User Location)
        map_view.userTrackingMode = .follow
    }
    
    func centerViewOnUserLocation() {
        if let location = location_manager.location?.coordinate {
            
            // Lat + Lon = How far we're zoomed in
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: region_in_meters, longitudinalMeters: region_in_meters)
            map_view.setRegion(region, animated: true)
        }
    }
    
    //  3. Only run app when user gives access to location
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:                                      // When App Open, Get located when in use
            centerViewOnUserLocation()
            setupMapView()
            location_manager.startUpdatingLocation()                    // Calls Delegate method
            populateNearByPlaces()
            
            // Makes "Search" request from Places API
            print("----CENTERING----")
//            if let location = location_manager.location?.coordinate {
//                print("------Fetching Data!------")
//                fetchData(latitude: location.latitude, longitude: location.longitude)
//                print("Lat: \(location.latitude), Lon: \(location.longitude)")
//            }
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
    // Do something when user moves around the map
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return } // if nil, do nothing
        
        // Makes the zoom in stay the position as the user moves
//        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: region_in_meters, longitudinalMeters: region_in_meters)
//
//        map_view.setRegion(region, animated: true)
    }
    
    
    // When user clicks allow, it immediately sets up the user's location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // When authorization changes
        checkLocationAuthorization()
    }
}

// Used for Places API Request
//  - Shows pins and window when clicked
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
