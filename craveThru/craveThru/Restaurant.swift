//
//  Restaurant.swift
//  craveThru
//
//  Created by Raymond Esteybar on 4/22/19.
//  Copyright © 2019 Eros Gonzalez. All rights reserved.
//

import MapKit
import AddressBook

class Restaurant: NSObject, MKAnnotation {
    let title: String?
    let address: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, address: String, coordinate: CLLocationCoordinate2D) {
        self.title = title;
        self.address = address
        self.coordinate = coordinate
    }
    
    var subtitle: String? {
        return address
    }
    
    class func from(restaurant: [String: Any]) -> Restaurant? {
        var title: String = ""
        var address: String = ""
        var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        // - Read JSON -> Store in Dictionary
        //  - Get Restaurant Name
        if let unwrapped_title = restaurant["name"] as? String {
            title = unwrapped_title
        } else {
            title = ""
        }
        
        //  - Get Location
        if let unwrapped_location = restaurant["location"] as? [String: Any] {
            address = unwrapped_location["address"] as? String ?? ""
            let lat = unwrapped_location["lat"] as? Double ?? 0
            let lng = unwrapped_location["lng"] as? Double ?? 0
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
    
        return Restaurant(title: title, address: address, coordinate: coordinate)
    }
}
