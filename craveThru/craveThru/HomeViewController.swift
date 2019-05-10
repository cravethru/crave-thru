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

let  MAX_BUFFER_SIZE = 3;
let  SEPERATOR_DISTANCE = 8;
let  TOPYAXIS = 75;

class HomeViewController: UIViewController {
    var db: Firestore!
    var prevVC: String!

    let location_manager = CLLocationManager()

    @IBOutlet weak var viewTinderBackGround: UIView!
    @IBOutlet weak var viewActions: UIView!
    
    var currentIndex = 0
    var currentLoadedCardsArray = [TinderCard]()
    var allCardsArray = [TinderCard]()
    var valueArray = ["1","2","3","4","5"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generateBarButtons()
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        viewActions.alpha = 0

//        if CLLocationManager.locationServicesEnabled() {
//            checkLocationAuthorization()
//        } else {
//            print("NOT ALLOWED LOCATION")
//        }
    }
    
    func generateBarButtons() {
        
        let titleImageView = UIButton(type: .system)
        let titleWidthConstraint = titleImageView.widthAnchor.constraint(equalToConstant: 35)
        let titleHeightConstraint = titleImageView.heightAnchor.constraint(equalToConstant: 35)
        titleImageView.setImage(UIImage(named: "logoColor")?.withRenderingMode(.alwaysOriginal), for: .normal)
        titleWidthConstraint.isActive = true
        titleHeightConstraint.isActive = true
        titleImageView.addTarget(self, action: #selector(onLogo), for: .touchUpInside)
        
        
        let profileButton = UIButton(type: .system)
        let profileWidthConstraint = profileButton.widthAnchor.constraint(equalToConstant: 35)
        let profileHeightConstraint = profileButton.heightAnchor.constraint(equalToConstant: 35)
        profileButton.setImage(UIImage(named: "userGray")?.withRenderingMode(.alwaysOriginal), for: .normal)
        profileHeightConstraint.isActive = true
        profileWidthConstraint.isActive = true
        profileButton.addTarget(self, action: #selector(self.onProfile), for: .touchUpInside)
        
        let mapButton = UIButton(type: .system)
        let mapWidthConstraint = mapButton.widthAnchor.constraint(equalToConstant: 40)
        let mapHeightConstraint = mapButton.heightAnchor.constraint(equalToConstant: 40)
        mapButton.setImage(UIImage(named: "LocationPinGray")?.withRenderingMode(.alwaysOriginal), for: .normal)
        mapHeightConstraint.isActive = true
        mapWidthConstraint.isActive = true
        mapButton.addTarget(self, action: #selector(onMap), for: .touchUpInside)
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: mapButton)
        navigationItem.titleView = titleImageView

    }
    
    @objc func onProfile() {
        print("Navigating to profile")
        
        if(prevVC == "prof") {
            self.dismiss(animated: false, completion: nil)
            return
        }
        
        self.performSegue(withIdentifier: "profileSegue", sender: self)
    }
    
    @objc func onMap() {
        print("Navigation to map screen")
        
        if(prevVC == "map") {
            self.dismiss(animated: false, completion: nil)
            return
        }
        
        self.performSegue(withIdentifier: "MapsSegue", sender: self)
    }
    
    @objc func onLogo() {
        print("Logo Clicked")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mapVC = segue.destination as? MapsViewController {
            mapVC.prevVC = "home"
        }
        if let profVC = segue.destination as? ProfileViewController {
            profVC.prevVC = "home"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        view.layoutIfNeeded()
        loadCardValues()
    }
    
    func loadCardValues() {
        
        if valueArray.count > 0 {
            
            let capCount = (valueArray.count > MAX_BUFFER_SIZE) ? MAX_BUFFER_SIZE : valueArray.count
            
            for (i,value) in valueArray.enumerated() {
                let newCard = createTinderCard(at: i,value: value)
                allCardsArray.append(newCard)
                if i < capCount {
                    currentLoadedCardsArray.append(newCard)
                }
            }
            
            for (i,_) in currentLoadedCardsArray.enumerated() {
                if i > 0 {
                    viewTinderBackGround.insertSubview(currentLoadedCardsArray[i], belowSubview: currentLoadedCardsArray[i - 1])
                }else {
                    viewTinderBackGround.addSubview(currentLoadedCardsArray[i])
                }
            }
            animateCardAfterSwiping()
            perform(#selector(loadInitialDummyAnimation), with: nil, afterDelay: 1.0)
        }
    }
    
    @objc func loadInitialDummyAnimation() {
        
        let dummyCard = currentLoadedCardsArray.first;
        dummyCard?.shakeAnimationCard()
        UIView.animate(withDuration: 1.0, delay: 2.0, options: .curveLinear, animations: {
            self.viewActions.alpha = 1.0
        }, completion: nil)
        //Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.animateEmojiView), userInfo: emojiView, repeats: true)
    }
    
    func createTinderCard(at index: Int , value :String) -> TinderCard {
        
        let card = TinderCard(frame: CGRect(x: 0, y: 0, width: viewTinderBackGround.frame.size.width , height: viewTinderBackGround.frame.size.height - 50) ,value : value)
        card.delegate = self
        return card
    }
    
    func removeObjectAndAddNewValues() {
        currentLoadedCardsArray.remove(at: 0)
        currentIndex = currentIndex + 1
        
        if (currentIndex + currentLoadedCardsArray.count) < allCardsArray.count {
            let card = allCardsArray[currentIndex + currentLoadedCardsArray.count]
            var frame = card.frame
            frame.origin.y = CGFloat(MAX_BUFFER_SIZE * SEPERATOR_DISTANCE)
            card.frame = frame
            currentLoadedCardsArray.append(card)
            viewTinderBackGround.insertSubview(currentLoadedCardsArray[MAX_BUFFER_SIZE - 1], belowSubview: currentLoadedCardsArray[MAX_BUFFER_SIZE - 2])
        }
        print(currentIndex)
        animateCardAfterSwiping()
    }
    
    func animateCardAfterSwiping() {
        for (i,card) in currentLoadedCardsArray.enumerated() {
            UIView.animate(withDuration: 0.5, animations: {
                if i == 0 {
                    card.isUserInteractionEnabled = true
                }
                var frame = card.frame
                frame.origin.y = CGFloat(i * SEPERATOR_DISTANCE)
                card.frame = frame
            })
        }
    }
    
    @IBAction func disLikeButtonAction(_ sender: Any) {
        
        let card = currentLoadedCardsArray.first
        card?.leftClickAction()
    }
    
    @IBAction func LikeButtonAction(_ sender: Any) {
        
        let card = currentLoadedCardsArray.first
        card?.rightClickAction()
    }
    
    @IBAction func onSaved(_ sender: Any) {
        //User interacts with saved button to add restaurant to their profile as favorited
        let user = Auth.auth().currentUser
        let destination = "favorited"
        let isAddedTo = true
        
        //API values here to create restaurant object
        let restaurant = Restaurant(restaurantAPIRequestId: "x", restaurantName: "x", typeOfFood: "x", menu: "x", distanceFromUser: 0.0, thumbnailUrl: "x")
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
            case .denied, .restricted:
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
            
            case .notDetermined:
                location_manager.requestWhenInUseAuthorization()
                break
            
            default:
                break
        }
    }
    
    @IBAction func detailButton(_ sender: Any) {
        performSegue(withIdentifier: "DetailSegue", sender: self)
    }
    
    @IBAction func mapsButton(_ sender: Any) {
        performSegue(withIdentifier: "MapsSegue", sender: self)
    }
}

extension HomeViewController : TinderCardDelegate{
    
    // action called when the card goes to the left.
    func cardGoesUp(card: TinderCard) {
        removeObjectAndAddNewValues()
    }
    // action called when the card goes to the right.
    func cardGoesDown(card: TinderCard) {
        removeObjectAndAddNewValues()
    }
    func currentCardStatus(card: TinderCard, distance: CGFloat) {
        
        if distance == 0 {
            //emojiView.rateValue =  2.5
        }else{
            let value = Float(min(abs(distance/100), 1.0) * 5)
            let sorted = distance > 0  ? 2.5 + (value * 5) / 10  : 2.5 - (value * 5) / 10
            //emojiView.rateValue =  sorted
        }
        
        
    }
}
