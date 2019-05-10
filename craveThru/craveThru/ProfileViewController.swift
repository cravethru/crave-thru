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
    
    var prevVC : UIViewController?
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var memberSinceLabel: UILabel!
    
    @IBOutlet weak var onSortByAllButton: UIButton!
    @IBOutlet weak var onSortBySavedButton: UIButton!
    @IBOutlet weak var onSortByLikedButton: UIButton!
    
    
    var imgArray = [UIImage(named: "1"), UIImage(named: "2"),UIImage(named: "3"),UIImage(named: "4"),UIImage(named: "5")]

    override func viewDidLoad() {
        super.viewDidLoad()
        generateBarButtons()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings

        db = Firestore.firestore()
        
        if Auth.auth().currentUser != nil{
            let user = Auth.auth().currentUser!
            let dbRef = db.collection("users").document(user.uid)
            getDataFromDatabase(dbRef: dbRef)
        }
        // Do any additional setup after loading the view.
    }
    
    func generateBarButtons() {
        
        let titleImageView = UIButton(type: .system)
        let titleWidthConstraint = titleImageView.widthAnchor.constraint(equalToConstant: 35)
        let titleHeightConstraint = titleImageView.heightAnchor.constraint(equalToConstant: 35)
        titleImageView.setImage(UIImage(named: "locoGray")?.withRenderingMode(.alwaysOriginal), for: .normal)
        titleWidthConstraint.isActive = true
        titleHeightConstraint.isActive = true
        titleImageView.addTarget(self, action: #selector(onLogo), for: .touchUpInside)
        
        let profileButton = UIButton(type: .system)
        let profileWidthConstraint = profileButton.widthAnchor.constraint(equalToConstant: 35)
        let profileHeightConstraint = profileButton.heightAnchor.constraint(equalToConstant: 35)
        profileButton.setImage(UIImage(named: "userColor")?.withRenderingMode(.alwaysOriginal), for: .normal)
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
        
    }
    
    @objc func onMap() {
        print("Navigation to map screen")
        
        if (type(of: prevVC) == type(of: MapsViewController())) {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        self.performSegue(withIdentifier: "MapsSegue", sender: self)
        
    }
    
    @objc func onLogo() {
        print("Logo Clicked")
        
        if (type(of: prevVC) == type(of: HomeViewController())) {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        self.performSegue(withIdentifier: "backHome", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? MapsViewController {
            destinationVC.prevVC = self;
        }
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
    
    // Actions
    @IBAction func onBackButton(_ sender: Any) {
        self.dismiss(animated:true , completion: nil)
    }
    
    @IBAction func onLogout(_ sender: Any) {
        do
        {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "logout", sender: self)
        }
        catch let error as NSError
        {
            print (error.localizedDescription)
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
