
//
//  ExpandedViewController.swift
//  craveThru
//
//  Created by Angel on 4/14/19.
//  Copyright © 2019 Eros Gonzalez. All rights reserved.
//

import UIKit



class ExpandedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var imageSwipe: UIImageView!
    
    let imageNames = ["0", "1", "2", "3", "4"]
    var currentImage = 0
    
    var restaurantName = String()
    var lat = 0.0
    var lon = 0.0

    var itemName = String()

    var menuCount = 0

    static var menuItemNames = [String]()
    static var menuCategories = [String]()
    static var itemCount: Int = 0
    
    
    static var restaurantMenu = Menu()
    
    @IBOutlet weak var restaurantNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGestureRight))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        imageSwipe.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGestureLeft))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        imageSwipe.addGestureRecognizer(swipeLeft)
  
        //TODO LEFT RIGHT TAPS
        
        // Do any additional setup after loading the view.
        print("In Expanded: Item Count = \(ExpandedViewController.itemCount)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        restaurantNameLabel.text = restaurantName
        print("View Will Appear")
    }
    
    
    class func assignDetails(menusOnCall: Menu){
        //will populate restaurant name, menu, etc.
        if menusOnCall.response.menu.menus.count > 0 {
            for entriesOnMenu in (menusOnCall.response.menu.menus.items?[0].entries.items)!{
                for menuNames in entriesOnMenu.entries.items {
                    self.menuItemNames.append(menuNames.name)
                    self.menuCategories.append(entriesOnMenu.name)
                    print (menuNames.name)
                    self.itemCount += 1
                }
            }
        }
    }
    @objc func respondToSwipeGestureRight() {
        if currentImage == 0 {
            currentImage = imageNames.count - 1
        }else{
            currentImage -= 1
        }
        imageSwipe.image = UIImage(named: imageNames[currentImage])
    }
    
    @objc func respondToSwipeGestureLeft() {
        if currentImage == imageNames.count - 1 {
            currentImage = 0
            
        }else{
            currentImage += 1
        }
        imageSwipe.image = UIImage(named: imageNames[currentImage])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let food_items = ExpandedViewController.restaurantMenu.response.menu.menus.items {
//
//            print ("Item count: \(food_items.count)")
//            return food_items.count
//
//        }
//
//        print ("no tablese")
        
        
        
        return ExpandedViewController.itemCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! MenuTableViewCell
        
        print (ExpandedViewController.menuItemNames[indexPath.row])
        
        cell.itemNameLabel.text = ExpandedViewController.menuItemNames[indexPath.row]
        cell.tagLabel.text = ExpandedViewController.menuCategories[indexPath.row]

//        if let food_items = ExpandedViewController.restaurantMenu.response.menu.menus.items {
//            cell.itemNameLabel.text = food_items[indexPath.row].name
//            cell.descriptionLabel.text = food_items[indexPath.row].description
//
//            print (cell.itemNameLabel.text, cell.descriptionLabel.text)
//        }
        
        return cell
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
