//
//  Restaurant.swift
//  craveThru
//
//  Created by Raymond Esteybar on 4/22/19.
//  Copyright © 2019 Eros Gonzalez. All rights reserved.
//

import MapKit
import AddressBook

struct Menu : Codable {
    struct Food : Codable {
        let name : String
        let description : String
    }

    struct AllFood : Codable {
        let items : [Food]
    }

    struct Category : Codable {
        let name : String           // Food Category
        let description : String    // Category Description
        let entries : AllFood
    }

    struct Entry : Codable {
        let count : Int
        let items : [Category]
    }

    struct Items : Codable {
        let menuId : String
        let name : String
        let description : String
        let entries: Entry
    }

    struct Menus : Codable {
        let count : Int
        let items : [Items]
    }

    struct Menu : Codable {
        let menus : Menus
    }

    struct Response : Codable {
        let menu : Menu
    }

    let response : Response
}

struct Test : Codable {
    struct Meta : Codable {
        let code : Int
    }
    
    let meta : Meta
}

class PlacesAPICaller {
    // Places API
    static let client_id = "UH3KGN3HLTNDN1DIA1EIY0FKN120TC5W2L1H22EFPXMZFHJF"
    static let client_secret = "OQ0F5RZWB53GZSWIKC4YWBTTJ4IDXQPPICLZQEUD3GQITVAA"
    
    // Current Date
    static var current_date : String = ""
    
    static var current_menu : [String : Any] = [:]
    
    // Requires current date in URL
    class func getDate() {
        // 1. Setup Date & Calendar
        let date = Date()
        let calendar = Calendar.current
        
        // 2. Get Date for Places API Request URLs
        let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: date)
        let year = components.year
        var check_month: String = ""
        var check_day: String = ""
        
        // 3. Format month
        if let unwrapped_month = components.month {
            if unwrapped_month >= 1 && unwrapped_month <= 9 {
                check_month = "0\(unwrapped_month)"
            } else {
                check_month = "\(unwrapped_month)"
            }
        }
        
        // 4. Format day
        if let unwrapped_day = components.day {
            if unwrapped_day >= 1 && unwrapped_day <= 9 {
                check_day = "0\(unwrapped_day)"
            } else {
                check_day = "\(unwrapped_day)"
            }
        }
        
        // 4. Setup Current Date
        current_date = "\(year!)\(check_month)\(check_day)"
    }
    
    class func getMenu(venue_id : String) -> [String : Any] {
        let menu_url = "https://api.foursquare.com/v2/venues/\(venue_id)/menu?client_id=\(client_id)&client_secret=\(client_secret)&v=\(current_date)"
        
        //  - Format URL
        guard let url = URL(string: menu_url) else { return [:] }
        
        print("--Printing Menu--")
        
        // 2. Parses JSON from "Search for Venues" request
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {return}
//            let dataAsString = String(data: data, encoding: .utf8)
//            print (dataAsString!)
            
            // - Read JSON -> Store in Dictionary
            do {
                //here dataResponse received from a network request
                let decoder = JSONDecoder()

                let model = try decoder.decode(Menu.self, from: data)
            } catch let parsingError {
                print("Error", parsingError)
            }
        }.resume()
        
        return self.current_menu
    }
    
    class func printMenu(entries : [String : Any]) {
        let menu = entries["items"] as! [String : Any]

        print(menu)
        
//        for section in menu {
//            let total_items = section["count"] as! Int
//
//            for item in 0...total_items {
//
//            }
//        }
    }
}
