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
    }
    
    struct AllFood : Codable {
        let items : [Food]
    }
    
    struct Category : Codable {
        let name : String           // Food Category
        let description : String?    // Category Description
        let entries : AllFood
    }
    
    struct Entry : Codable {
        let count : Int
        let items : [Category]
    }
    
    struct Item : Codable {
        let name : String
        let description : String?
        let entries: Entry
    }
    
    struct Menus : Codable {
        let count : Int
        let items : [Item]?
    }
    
    struct Menu : Codable {
        let menus : Menus
    }
    
    struct Response : Codable {
        let menu : Menu
    }
    
    let response : Response
}

struct Restaurant : Codable{
    struct Venue : Codable{
        let id : String
        let name : String
    }
    
    struct Response : Codable{
        let venues : [Venue]
    }
    
    let response : Response
}
