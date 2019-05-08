//
//  Restaurant.swift
//  craveThru
//
//  Created by Raymond Esteybar on 4/22/19.
//  Copyright © 2019 Eros Gonzalez. All rights reserved.
//

import MapKit
import AddressBook

class PlacesAPICaller {
    // Places API
    static let client_id = "UH3KGN3HLTNDN1DIA1EIY0FKN120TC5W2L1H22EFPXMZFHJF"
    static let client_secret = "OQ0F5RZWB53GZSWIKC4YWBTTJ4IDXQPPICLZQEUD3GQITVAA"
    
    // Current Date
    static var current_date : String = ""
    
    // Requires current date in URL
    class func getDate() {
        // 1. Setup Date & Calendar
        let date = Date()
        let calendar = Calendar.current
        
        // 2. Get Date for Places API Request URLs
        let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: date)
        let year = components.year
        var formatted_month: String = ""
        var formatted_day: String = ""
        
        // 3. Format month
        if let unwrapped_month = components.month {
            if unwrapped_month >= 1 && unwrapped_month <= 9 {
                formatted_month = "0\(unwrapped_month)"
            } else {
                formatted_month = "\(unwrapped_month)"
            }
        }
        
        // 4. Format day
        if let unwrapped_day = components.day {
            if unwrapped_day >= 1 && unwrapped_day <= 9 {
                formatted_day = "0\(unwrapped_day)"
            } else {
                formatted_day = "\(unwrapped_day)"
            }
        }
        
        // 4. Setup Current Date
        current_date = "\(year!)\(formatted_month)\(formatted_day)"
    }
    
    class func getMenu(venue_id : String, completion: @escaping (Bool, Menu) -> Void) {
        let menu_url = "https://api.foursquare.com/v2/venues/\(venue_id)/menu?client_id=\(client_id)&client_secret=\(client_secret)&v=\(current_date)"
        
        //  - Format URL
        guard let url = URL(string: menu_url) else { return }
        
        // 2. Parses JSON from "Menu" request
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {return}
            
            do {
                let decoder = JSONDecoder()
                
                print("Checking Menu")
                let menu = try decoder.decode(Menu.self, from: data)
                
                // Ensures that the restaurant contains a menu
                let is_menu_available = menu.response.menu.menus.count > 0
                
                print("# of menus: \(menu.response.menu.menus.count)")
                
                if is_menu_available {
                    completion(true, menu)
                } else {
                    completion(false, menu)
                }
            } catch let parsingError {
                print("Error", parsingError)
            }
        }.resume()
    }
    
    class func printMenu(menu : Menu) {
        let menus = menu.response.menu.menus.items
        
        for m in menus {
            print("Name of Menu: \(m.name)")
            
            let sections = m.entries.items
            print(sections.count)
            for s in sections {
                print("\t\(s.name)")
                
                var counter = 1
                let food = s.entries.items
                for f in food {
                    print("\t\t\(counter)) \(f.name)")
                    counter += 1
                }
            }
        }
    }
}
