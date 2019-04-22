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

    
    var locationla = 37.3382;
    var locationlo = -121.8863;
    
   
            
        override func viewDidLoad() {
            super.viewDidLoad()
            
            var url = URL(string: "https://api.foursquare.com/v2/venues/search?ll=locationla, locationlo&categoryId/4bf58dd8d48988d145941735&client_id=UH3KGN3HLTNDN1DIA1EIY0FKN120TC5W2L1H22EFPXMZFHJF&/client_secret=OQ0F5RZWB53GZSWIKC4YWBTTJ4IDXQPPICLZQEUD3GQITVAA")!
            
            
            let jsonString = "https://api.foursquare.com/v2/venues/search?ll=\(locationla),\(locationlo)&categoryId=\(food_id)&client_id=\(client_id)&client_secret=\(client_secret)&v=20190417"
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
            let task = session.dataTask(with: request) { (data, response, error) in
                // This will run when the network request returns
                if let error = error {
                    print(error.localizedDescription)
                } else if let data = data {
                    let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    
                    
                    
                    print(dataDictionary)
                    
                    // TODO: Get the array of movies
                    // TODO: Store the movies in a property to use elsewhere
                    // TODO: Reload your table view data
                    
                }
            
        }
         task.resume()        // Do any additional setup after loading the view.
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
