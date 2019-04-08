//
//  MapsViewController.swift
//  craveThru
//
//  Created by Raymond Esteybar on 4/7/19.
//  Copyright © 2019 Eros Gonzalez. All rights reserved.
//

import UIKit
import MapKit

class MapsViewController: UIViewController {

    @IBOutlet weak var map_view: MKMapView!
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
