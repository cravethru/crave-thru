
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
    
    let imageNames = ["1", "2", "3", "4", "5"]
    var currentImage = 0
    
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
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! MenuTableViewCell
        
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
