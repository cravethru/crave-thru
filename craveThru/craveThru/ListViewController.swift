//
//  ListViewController.swift
//  craveThru
//
//  Created by Angel on 4/15/19.
//  Copyright © 2019 Eros Gonzalez. All rights reserved.
//


//to do michael

import UIKit
import MapKit
import Alamofire

class ListViewController: UIViewController {

    
    
    @IBOutlet weak var restN: UILabel!
    
    
    @IBOutlet weak var restP: UILabel!
    
    
    @IBOutlet weak var restD: UILabel!
    
    
    
    
    var locationla = "37.3382";
    var locationlo = "-121.8863";
    
   
            
        override func viewDidLoad() {
            super.viewDidLoad()
            
            
            let ven_id = "4bcca12bb6c49c7422169491"
            
            let client_id = "UH3KGN3HLTNDN1DIA1EIY0FKN120TC5W2L1H22EFPXMZFHJF"
            let client_secret = "OQ0F5RZWB53GZSWIKC4YWBTTJ4IDXQPPICLZQEUD3GQITVAA"
            
            var myUrl =  "https://api.foursquare.com/v2/venues/search?ll=\(locationla),\(locationlo)&categoryId=\(ven_id)&client_id=\(client_id)&client_secret=\(client_secret)&v=20190422";
            
            
            guard let url = URL(string: myUrl) else { return }
            
            URLSession.shared.dataTask(with: url){ (data, response, err) in
                
                guard let data = data else {return}
                let dataAsString = String(data: data, encoding: .utf8)
                print("hello")
                print(dataAsString)
                
               // Do any additional setup after loading the view.
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
