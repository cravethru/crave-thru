//
//  JsonObjects.swift
//  craveThru
//
//  Created by Raymond Esteybar on 5/6/19.
//  Copyright © 2019 Eros Gonzalez. All rights reserved.
//

import Foundation

struct Menu : Codable {
    struct Food : Codable {
        let name : String
        let description : String?
        
        init() {
            name = ""
            description = ""
        }
    }
    
    struct AllFood : Codable {
        let items : [Food]
        
        init() {
            items = []
        }
    }
    
    struct Category : Codable {
        let name : String           // Food Category
        let description : String?    // Category Description
        let entries : AllFood
        
        init() {
            name = ""
            description = ""
            entries = AllFood()
        }
    }
    
    struct Entry : Codable {
        let count : Int
        let items : [Category]
        
        init() {
            count = 0
            items = []
        }
    }
    
    struct Item : Codable {
        let name : String
        let description : String?
        let entries: Entry
        
        init() {
            name = ""
            description = ""
            entries = Entry()
        }
    }
    
    struct Menus : Codable {
        let count : Int
        let items : [Item]?
        
        init() {
            count = 0
            items = []
        }
    }
    
    struct Menu : Codable {
        let menus : Menus
        
        init() {
            menus = Menus()
        }
    }
    
    struct Response : Codable {
        let menu : Menu
        
        init() {
            menu = Menu()
        }
    }
    
    let response : Response
    
    init() {
        response = Response()
    }
}

struct Restaurant : Codable {
    struct Location : Codable {
        
    }
    
    struct Venue : Codable {
        let id : String
        let name : String
        let location : Location
    }
    
    struct Response : Codable {
        let venues : [Venue]
    }
    
    let response : Response
}
