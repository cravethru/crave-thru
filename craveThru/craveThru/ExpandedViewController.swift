
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
    
    var restaurantMenu = Menu()
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        restaurantNameLabel.text = restaurantName
        
        PlacesAPICaller.getMenu(restaurant_name: restaurantName, lat: lat, lon: lon) { (isFinished, menu) in
            if isFinished {
                self.restaurantMenu = menu
                
                print ("LMOA")
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
        if let food_items = restaurantMenu.response.menu.menus.items {
            return food_items.count
            
            print ("yes tables")
        }
        
        print ("no tablese")
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! MenuTableViewCell
        
        if let food_items = restaurantMenu.response.menu.menus.items {
            cell.itemNameLabel.text = food_items[indexPath.row].name
            cell.descriptionLabel.text = food_items[indexPath.row].description
            
            print (cell.itemNameLabel.text, cell.descriptionLabel.text)
        }
        
        print ("penis")
        
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
