//
//  LoginViewController.swift
//  craveThru
//
//  Created by Angel on 4/8/19.
//  Copyright © 2019 Eros Gonzalez. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var signup: UIButton!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let boldText = "Sign up."
        let regularText = "Need an account "
        let text = NSMutableAttributedString(string: "\(regularText)\(boldText)")
        
        let boldSizeStart = regularText.count
        
       text.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 14), range: NSMakeRange(boldSizeStart, boldText.count))
        
       signup.setAttributedTitle(text, for:UIControl.State.normal)
        // Do any additional setup after loading the view.
    }
    

    @IBAction func onLogin(_ sender: Any) {
        
        self.performSegue(withIdentifier: "LoginSegueue", sender: self)
        
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
