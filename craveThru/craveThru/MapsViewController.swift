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
    
    var prevVC : String!
    static let region_in_meters: Double = 10000
    static var location_manager = CLLocationManager()
    static var all_restaurants = [MKMapItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateBarButtons()
        PlacesAPICaller.getDate()
        checkLocationServices()
//        checkLocationAuthorization()
        populateAnnotations()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    // Searches a Location
    //  - Displays Search Bar
//    @IBAction func searchButton(_ sender: Any) {
//        let search_controller = UISearchController(searchResultsController: nil)
//        search_controller.searchBar.delegate = self
//        present(search_controller, animated: true, completion: nil)
//    }
    
    // Draws navigation bar
    func generateBarButtons() {
        
        let titleImageView = UIButton(type: .system)
        let titleWidthConstraint = titleImageView.widthAnchor.constraint(equalToConstant: 35)
        let titleHeightConstraint = titleImageView.heightAnchor.constraint(equalToConstant: 35)
        titleImageView.setImage(UIImage(named: "locoGray")?.withRenderingMode(.alwaysOriginal), for: .normal)
        titleWidthConstraint.isActive = true
        titleHeightConstraint.isActive = true
        titleImageView.addTarget(self, action: #selector(onLogo), for: .touchUpInside)
        
        let profileButton = UIButton(type: .system)
        let profileWidthConstraint = profileButton.widthAnchor.constraint(equalToConstant: 35)
        let profileHeightConstraint = profileButton.heightAnchor.constraint(equalToConstant: 35)
        profileButton.setImage(UIImage(named: "userGray")?.withRenderingMode(.alwaysOriginal), for: .normal)
        profileHeightConstraint.isActive = true
        profileWidthConstraint.isActive = true
        profileButton.addTarget(self, action: #selector(self.onProfile), for: .touchUpInside)
        
        let mapButton = UIButton(type: .system)
        let mapWidthConstraint = mapButton.widthAnchor.constraint(equalToConstant: 40)
        let mapHeightConstraint = mapButton.heightAnchor.constraint(equalToConstant: 40)
        mapButton.setImage(UIImage(named: "LocationPin")?.withRenderingMode(.alwaysOriginal), for: .normal)
        mapHeightConstraint.isActive = true
        mapWidthConstraint.isActive = true
        mapButton.addTarget(self, action: #selector(onMap), for: .touchUpInside)
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: mapButton)
        navigationItem.titleView = titleImageView
        
    }
    
    @objc func onProfile() {
        print("Navigating to profile")
        
        if (prevVC == "prof") {
            self.dismiss(animated: false, completion: nil)
            return
        }
        
        self.performSegue(withIdentifier: "profileSegue", sender: self)
        
    }
    
    @objc func onMap() {
        print("Navigation to map screen")
        
    }
    
    @objc func onLogo() {
        print("Logo Clicked")
        
        if (prevVC == "home") {
            self.dismiss(animated: false, completion: nil)
            return
        }
        
        self.performSegue(withIdentifier: "backHome", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ProfileViewController {
            destinationVC.prevVC = "map";
        }
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
            
//            print("Latitude: \(latitude) Longitude: \(longitude)")
            
            // Zoom in on annotation
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // How much we want to be zoomed in at that coordinate
            let region = MKCoordinateRegion(center: coordinate, span: span)
            
            self.map_view.region = region
            
            // Create Annotations
            //  - Show restaurants
            MapsViewController.requestRestaurants(completion: { (is_finished) in
                if is_finished {
                    self.populateAnnotations()
                }
            })
        }
    }
    
    // Initialize
    //  1. Check if User Enabled Location
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            // Setup location manager
            print("Location Services is Enabled, going to setup location manager")
            setupLocationManager()
            centerViewOnUserLocation()
            setupMapView()
        } else {
            // Show alert letting the user know they have to turn this on
            print("Location Services Not enabled")
        }
    }
    
    func setupMapView() {
        map_view.delegate = self as? MKMapViewDelegate
        map_view.showsUserLocation = true                           // Puts blue dot on map (User Location)
    }
    
    func centerViewOnUserLocation() {
        if let location = MapsViewController.location_manager.location?.coordinate {
            // Lat & Lon = How far we're zoomed in
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: MapsViewController.region_in_meters, longitudinalMeters: MapsViewController.region_in_meters)
            map_view.setRegion(region, animated: true)
        }
    }
    
        //  2. Set up for User Location
    func setupLocationManager() {
        MapsViewController.location_manager.delegate = self as? CLLocationManagerDelegate
        MapsViewController.location_manager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        MapsViewController.location_manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // 4. Display pin to for each restaurant on Map
    func populateAnnotations() {
        let restaurants = MapsViewController.all_restaurants
        
        for item in restaurants {
            let annotation = MKPointAnnotation()
            
            //  - Store ea. restaurant's info
            annotation.title = item.name
            annotation.coordinate = item.placemark.coordinate
            
            //  - Pin
            DispatchQueue.main.async {
                self.map_view.addAnnotation(annotation)
            }
        }
    }
    
    // 4. Use Apple's Local Search for Restaurants
    class func requestRestaurants(completion : @escaping (Bool) -> Void) {
        if let location = MapsViewController.location_manager.location?.coordinate {
            let categories = ["Restaurants", "Fast Food"]
            
            all_restaurants.removeAll()
            
            //  - Search
            for category in categories {
                getCategoryRestaurants(category: category, location: location) { (restaurants_found) in
                    
//                    print("\t\t\(category)'s menu")
//                    for r in restaurants_found {
//                        print("\t\t\t\(String(describing: r.name))")
//                    }
                    
                    all_restaurants.append(contentsOf: restaurants_found)
                }
            }
        }
    }
    
    class func getCategoryRestaurants(category : String, location : CLLocationCoordinate2D, completion: @escaping ([MKMapItem]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = category
        request.region = MKCoordinateRegion.init(center: location, latitudinalMeters: region_in_meters, longitudinalMeters: region_in_meters)
        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            guard let response = response else { return }
            
            print(category)
            
            //  - Return the restaurants
            completion(response.mapItems)
        }
    }
}
