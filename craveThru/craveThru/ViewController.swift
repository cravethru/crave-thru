//
//  ViewController.swift
//  craveThru
//
//  Created by Eros Gonzalez on 4/4/19.
//  Copyright © 2019 Eros Gonzalez. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var map_view: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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

    func startStandardUpdates() {
        // Create the location manager if this object does not already have one
        
        
        
    }

}

