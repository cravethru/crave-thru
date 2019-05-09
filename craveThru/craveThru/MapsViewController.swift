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
    static var all_restaurants: [MKMapItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PlacesAPICaller.getDate()
        checkLocationServices()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
            
            print("Latitude: \(latitude) Longitude: \(longitude)")
            
            // Zoom in on annotation
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // How much we want to be zoomed in at that coordinate
            let region = MKCoordinateRegion(center: coordinate, span: span)
            
            self.map_view.region = region
            
            // Create Annotations
            //  - Show restaurants
            self.populateNearByPlaces()
        }
    }
    
    // Initialize
    //  1. Check if User Enabled Location
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            // Setup location manager
            setupLocationManager()
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
    
    // 3. Only run app when user gives access to location
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                // When App Open, Get located when in use
                centerViewOnUserLocation()
                setupMapView()
                location_manager.startUpdatingLocation()                    // Calls Delegate method
                populateNearByPlaces()
                
                break
                
            case .denied, .restricted:
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
            
            case .notDetermined:
                location_manager.requestWhenInUseAuthorization()
                print("Not determined")
                break
        }
    }
    
    func setupMapView() {
        map_view.delegate = self as? MKMapViewDelegate
        map_view.showsUserLocation = true                           // Puts blue dot on map (User Location)
    }
    
    func centerViewOnUserLocation() {
        if let location = location_manager.location?.coordinate {
            // Lat & Lon = How far we're zoomed in
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: region_in_meters, longitudinalMeters: region_in_meters)
            map_view.setRegion(region, animated: true)
        }
    }
    
    // 4. Use Apple's Local Search for Restaurants
    func populateNearByPlaces() {
        let request = MKLocalSearch.Request()
        request.region = self.map_view.region
        
        //  - Used to store all restaurants within the user location
//        let defaults = UserDefaults.standard
        let categories = ["Restaurants", "Fast Food"]
        
        //  - Search
        for category in categories {
            request.naturalLanguageQuery = category
            let search = MKLocalSearch(request: request)
            
            search.start { (response, error) in
                guard let response = response else { return }
//                print(category)
                
//                var counter = 1
                
                //  - Create Annotations on Map
                for item in response.mapItems {
                    let annotation = MKPointAnnotation()
//                    let lat = item.placemark.coordinate.latitude
//                    let lon = item.placemark.coordinate.longitude
                    
                    //  - Store ea. restaurant's info
                    annotation.title = item.name
                    annotation.coordinate = item.placemark.coordinate
                    
//                    print("\(counter)) \(String(describing: item.name)) = Lat: \(lat), Lon: \(lon)")
//                    counter += 1
                    
                    //  - Store Restaurant
//                    self.all_restaurants.append(item)
                    DispatchQueue.main.async {
                        self.map_view.addAnnotation(annotation)
                    }
                }
            }
        }
        
//        let kfc_venue_id = "4f32039619833175d609c7e4"
//        let subway_id = "4f32039619833175d609c7e4" // It's KFC
//        let subway_id = "50bd3985e4b0e286cdea0b6a"
//        let venue_id = "540686c4498e1d19d58460c5" // It's Panera Bread
//        PlacesAPICaller.getMenu(venue_id: venue_id, completion: { finished, menu in
//            if finished {
//                print("Success")
//                print(menu.response.menu.menus.count)
//                PlacesAPICaller.printMenu(menu: menu)
//            } else {
//                print("YOU FAILURE")
//            }
//        })

//        print(menu.response.menu.menus.items[0].name)
//        PlacesAPICaller.printMenu(entries: menu)
        
//            // Store all Restaurant names from:
//            //  - Restaurant & Fast Food
//            defaults.set(Array(self.all_restaurants), forKey: "restaurant")
//
//            //  - Force UserDefaults to save
//            defaults.synchronize()
//
//            NotificationCenter.default.post(name: Notification.Name("get_restaurants"), object: nil, userInfo: nil)
//        }
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
//        populateNearByPlaces()
    }
    
    // When user clicks allow, it immediately sets up the user's location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // When authorization changes
        checkLocationAuthorization()
    }
}
