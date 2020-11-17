//
//  PlantViewController.swift
//  SmartGarden
//
//  Created by England Kwok on 3/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Cosmos

class PlantViewController: UIViewController {
    
    @IBOutlet weak var autoWateringSwitch: UISwitch!
    @IBOutlet weak var waterTankVolume: CosmosView!
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var plantImageView: UIImageView!
    var ref: DatabaseReference?
    var plant: Plant?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plantNameLabel.text = plant?.plantName
        plantImageView.image = UIImage(data: (plant?.plantPhoto)!)

        //set the reference of firebase
        ref = Database.database().reference()
        
        //retrieve
//        ref?.observeSingleEvent(of: .value, with: { (snapshot) in
//            let value = snapshot.value as? NSDictionary
//            let childVal = value?.allValues.first as? NSDictionary
//
//            let temperature = childVal?["Temperature"] as! Double
//            let string = String(format: "%.2f", temperature)
//            do{
////                try self.dummyLabel.text = string
//            } catch{
//                print("dummyLabel error")
//            }
//
//        })
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
