//
//  YelpAPICaller.swift
//  craveThru
//
//  Created by Raymond Esteybar on 5/7/19.
//  Copyright © 2019 Eros Gonzalez. All rights reserved.
//

import Foundation

class YelpAPICaller {
    let client_id = "bY2HHd2SJLIhYXZYLnnT_Q"
    let api_key = "hTYF7-rb3s5YvDbH4BtsByLIBaATYCUksKeyNpWAFiDgOfi5EzSrA8YRhqPIUiKUv-p9Ey2E31cHLvCpKbWXBHgT3MKUrr5p7Sbn-ZoeYg91OT-CAZGhedpHC6O3XHYx"
    
    class func getNearbyRestaurants(lat: Double, lon: Double, completion: @escaping (Bool, Menu) -> Void) {
        let search_url = "https://api.yelp.com/v3/businesses/search?latitude=\(lat)&longitude=\(lon)"
        
        //  - Format URL
        guard let url = URL(string: search_url) else { return }
        
        // 2. Parses JSON from "Menu" request
//        URLSession.shared.dataTask(with: url) { (data, response, err) in
//            guard let data = data else {return}
//
//            do {
//                let decoder = JSONDecoder()
//
//                let menu = try decoder.decode(Venues.self, from: data)
//
//                // Ensures that the restaurant contains a menu
//                let is_menu_available = menu.response.menu.menus.count > 0
//
//                if is_menu_available {
//                    completion(true, menu)
//                } else {
//                    completion(false, menu)
//                }
//            } catch let parsingError {
//                print("Error", parsingError)
//            }
//            }.resume()
    }
}
