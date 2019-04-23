//
//  ProfileViewController.swift
//  craveThru
//
//  Created by Angel on 4/14/19.
//  Copyright © 2019 Eros Gonzalez. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    var db: Firestore!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var memberSinceLabel: UILabel!
    
    @IBOutlet weak var onSortByAllButton: UIButton!
    @IBOutlet weak var onSortBySavedButton: UIButton!
    @IBOutlet weak var onSortByLikedButton: UIButton!
    
    
    var imgArray = [UIImage(named: "1"), UIImage(named: "2"),UIImage(named: "3"),UIImage(named: "4"),UIImage(named: "5")]

    override func viewDidLoad() {
        super.viewDidLoad()
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings

        db = Firestore.firestore()
        
        let user = Auth.auth().currentUser!
        let dbRef = db.collection("users").document(user.uid)
        
        getDataFromDatabase(dbRef: dbRef)
        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserProfileFavoritesCollectionViewCell", for: indexPath) as! UserProfileFavoritesCollectionViewCell
        
        cell.carouselImage.layer.cornerRadius = 25.0
        cell.contentView.layer.masksToBounds = true
        
        cell.carouselImage.image = imgArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "ProfileFavoritesTableViewCell", for: indexPath) as! ProfileFavoritesTableViewCell
        
        cell.restaurantImage.layer.cornerRadius = 50.0
        
        return cell
    }
    
    @IBAction func onSortByAll(_ sender: Any) {
        //sorts restuarants alhphabetically
        if onSortByAllButton.currentImage == UIImage(named: "list_color"){
            onSortByAllButton.setImage(UIImage(named: "list_gray"), for: .normal)
        }
        else{
            onSortByAllButton.setImage(UIImage(named: "list_color"), for: .normal)
        }
        
    }
    
    @IBAction func onSortBySaved(_ sender: Any) {
        //sorts restaurants alphabetically and if saved button was tapped
        if onSortBySavedButton.currentImage == UIImage(named: "logoColorPlus"){
            onSortBySavedButton.setImage(UIImage(named: "logoGrayPlus"), for: .normal)
        }
        else{
            onSortBySavedButton.setImage(UIImage(named: "logoColorPlus"), for: .normal)
        }
    }
    
    @IBAction func onSortByLiked(_ sender: Any) {
        //sorts restaurants alphabetically and if restaurant was swipped right
        if onSortByLikedButton.currentImage == UIImage(named: "color_check_mark"){
            onSortByLikedButton.setImage(UIImage(named: "gray_check_mark"), for: .normal)
        }
        else{
            onSortByLikedButton.setImage(UIImage(named: "color_check_mark"), for: .normal)
        }
    }
    
    
    
    func getDataFromDatabase(dbRef: DocumentReference){
        dbRef.getDocument{ (document, error) in
            if let document = document, document.exists {
                self.setProfileLabels(document: document)
            }
            else {
                print("Document does not exist")
            }
        }
    }
    
    func setProfileLabels(document: DocumentSnapshot){
        let dataDescription = document.data()!
        
        if let data = dataDescription["username"] as? String{
            self.usernameLabel.text = data
        }
        if let data = dataDescription["creationDate"] as? String{
            self.memberSinceLabel.text = data
        }
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
