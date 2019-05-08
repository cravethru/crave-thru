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
        var name : String
        var description : String?

        init() {
            name = ""
            description = ""
        }
    }

    struct AllFood : Codable {
        var items : [Food]

        init() {
            items = []
        }
    }

    struct Category : Codable {
        var name : String           // Food Category
        var description : String?    // Category Description
        var entries : AllFood

        init() {
            name = ""
            description = ""
            entries = AllFood()
        }
    }

    struct Entry : Codable {
        var count : Int?
        var items : [Category]?

        init() {
            count = 0
            items = []
        }
    }

    struct Item : Codable {
        var name : String
        var description : String?
        var entries: Entry

        init() {
            name = ""
            description = ""
            entries = Entry()
        }
    }

    struct Menus : Codable {
        var count : Int
        var items : [Item]?

        init() {
            count = 0
            items = []
        }
    }

    struct Menu : Codable {
        var menus : Menus

        init() {
            menus = Menus()
        }
    }

    struct Response : Codable {
        var menu : Menu

        init() {
            menu = Menu()
        }
    }

    var response : Response

    init() {
        response = Response()
    }
}

struct NoMenu : Codable {
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
    
    struct Menus : Codable {
        let count : Int
    }
    
    struct Menu : Codable {
        let menus : Menus
    }
    
    struct Response : Codable {
        let menu : Menu
    }
    
    let response : Response
}
