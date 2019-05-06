//
//  HomeViewController.swift
//  craveThru
//
//  Created by Angel on 4/8/19.
//  Copyright © 2019 Eros Gonzalez. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class HomeViewController: UIViewController {
    var db: Firestore!

    let location_manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        let image = UIImage(named: "logoColor.png")
        imageView.image = image
        navigationItem.titleView = imageView
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        
        // Testing All Restaurants show
//        let defaults = UserDefaults.standard
//        print(defaults.array(forKey: "restaurant_names") ?? "Nothing")

        if CLLocationManager.locationServicesEnabled() {
            location_manager.requestWhenInUseAuthorization()
            checkLocationAuthorization()
        } else {
            print("NOT ALLOWED LOCATION")
        }
        
        // * Used to Automatically update the default tip from different view
//        NotificationCenter.default.addObserver(self, selector: #selector(notification_fired(_:)), name: Notification.Name("get_restaurants"), object: nil)
    }
    
    @objc func notification_fired(_ notification: Notification) {
//        let defaults = UserDefaults.standard
//        let restaurants: Array = defaults.array(forKey: "restaurants") as! [MKMapItem]
        
        print("Got notification! In Home View")
//
//        var i = 0
//        for r in restaurants {
//            print("\(i)) \(String(describing: r.name))")
//            i += 1
//        }
    }
    
    @IBAction func onSaved(_ sender: Any) {
        //User interacts with saved button to add restaurant to their profile as favorited
        let user = Auth.auth().currentUser
        let destination = "favorited"
        let isAddedTo = true
        
        //API values here to create restaurant object
        var restaurant = Restaurant(restaurantAPIRequestId: "x", restaurantName: "x", typeOfFood: "x", menu: "x", distanceFromUser: 0.0, thumbnailUrl: "x")
        restaurant.setAddress(street: "x", city: "x", state: "x", country: "x", zip: 0.0)
        
        restaurant.setIsAddedTo(destination: destination, isAddedTo: isAddedTo)
        //End
        
        let apiID = restaurant.restaurantAPIRequestId
        let name = restaurant.restaurantName
        let food = restaurant.typeOfFood
        let menu = restaurant.menu
        let distance = restaurant.distanceFromUser
        let pic = restaurant.thumbnailUrl
        let address = restaurant.fullAddress
        let addedTo = restaurant.isAddedTo
        
        addRestaurantToDatabase(uid: user!.uid, restaurantAPIRequestId: apiID, restaurantName: name, typeOfFood: food, menu: menu, distanceFromUser: distance, thumbnailUrl: pic, fullAddress: address, isAddedTo: addedTo)
    }
    
    /*Function: Add restaurants to liked{
        //User interacts with swipe to add restaurant to their profile as liked
        let user = Auth.auth().currentUser
        let destination = "liked"
        let isAddedTo = true
 
         //API values here to create restaurant object
         var restaurant = Restaurant(restaurantAPIRequestId: "x", restaurantName: "x", typeOfFood: "x", menu: "x", distanceFromUser: 0.0, thumbnailUrl: "x")
         restaurant.setAddress(street: "x", city: "x", state: "x", country: "x", zip: 0.0)
 
         restaurant.setIsAddedTo(destination: destination, isAddedTo: isAddedTo)
         //End
 
         let apiID = restaurant.restaurantAPIRequestId
         let name = restaurant.restaurantName
         let food = restaurant.typeOfFood
         let menu = restaurant.menu
         let distance = restaurant.distanceFromUser
         let pic = restaurant.thumbnailUrl
         let address = restaurant.fullAddress
         let addedTo = restaurant.isAddedTo
 
         addRestaurantToDatabase(uid: user!.uid, restaurantAPIRequestId: apiID, restaurantName: name, typeOfFood: food, menu: menu, distanceFromUser: distance, thumbnailUrl: pic, fullAddress: address, isAddedTo: addedTo)
         }
     End function*/
    
    //Adds data from API to database: User id, restaurant id from api, restaurant name, type of food, menu,
    //distance from user, thumbnail url, address[String:Any], and added to[String:Bool]
    func addRestaurantToDatabase(uid: String, restaurantAPIRequestId: String, restaurantName: String, typeOfFood: String, menu: String, distanceFromUser: Double, thumbnailUrl: String, fullAddress: Dictionary<String, Any>, isAddedTo: Dictionary<String, Bool>){
        db.collection("users").document(uid).collection("savedRestaurants").document(restaurantAPIRequestId).setData([
            "restaurantAPIRequestId": restaurantAPIRequestId,
            "restaurantName": restaurantName,
            "fullAddress": fullAddress,
            "typeOfFood": typeOfFood,
            "distanceFromUser": distanceFromUser,
            "isAddedTo": isAddedTo
        ]) {err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(uid)")
            }
        }
    }
    
    class Restaurant{
        //Restaurant object for easy reusability using Places API
        var restaurantAPIRequestId: String
        var restaurantName: String
        var typeOfFood: String
        var menu: String
        var distanceFromUser: Double
        var thumbnailUrl: String
        var fullAddress: Dictionary <String, Any>
        var isAddedTo: Dictionary <String, Bool> //flags: user added object to "favorites" or swipped to "like"
        
        //initializes memember variables to default values
        init(restaurantAPIRequestId: String, restaurantName: String, typeOfFood: String, menu: String, distanceFromUser: Double, thumbnailUrl: String) {
            self.restaurantAPIRequestId = restaurantAPIRequestId
            self.restaurantName = restaurantName
            self.typeOfFood = typeOfFood
            self.menu = menu
            self.distanceFromUser = distanceFromUser
            self.thumbnailUrl = thumbnailUrl
            
            self.fullAddress = ["street": "STRING",
                                "city": "STRING",
                                "state": "STRING",
                                "country": "STRING",
                                "zip": 0]
            
            self.isAddedTo = ["favorited": false, //favorited: permanent
                              "liked": false] //liked: deleted after 24 hours
            
        }
        
        func setIsAddedTo(destination: String, isAddedTo: Bool){
            //needs error checking for either liked or favorited
            //condition: cannot have both
            self.isAddedTo[destination] = isAddedTo
        }
        
        func setAddress(street: String, city: String, state: String, country: String, zip: Double){
            self.fullAddress["street"] = street
            self.fullAddress["city"] = city
            self.fullAddress["state"] = state
            self.fullAddress["country"] = country
            self.fullAddress["zip"] = zip
        }
        
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
            case .denied, .restricted, .notDetermined:
                // Denied: Not allowed, denied once? Pop up won't show up
                // Restricted: User cannot change app status, Ex: Parent restricts child's location
                //    - Show alert instructing them how to turn on permission
                let title = "Location Services Disabled"
                let message = "Please enable Location Services in Settings > CraveThru > Location > While Using the App."
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

                let settings_action = UIAlertAction(title: "Settings", style: .default) { (UIAlertAction) in
                    guard let settings_url = URL(string: UIApplication.openSettingsURLString) else { return }

                    if UIApplication.shared.canOpenURL(settings_url) {
                        UIApplication.shared.open(settings_url, options: [:], completionHandler: { (success) in
                            print("Settings opened: \(success)")
                        })
                    }
                }

                alert.addAction(settings_action)
                present(alert, animated: true, completion: nil)
                break
            
            default:
                break
        }
    }
    
    @IBAction func detailButton(_ sender: Any) {
        performSegue(withIdentifier: "DetailSegue", sender: self)
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
