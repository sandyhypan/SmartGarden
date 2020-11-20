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
    var userID: String = ""
    var counter: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = UserDefaults.standard
        userID = userDefaults.string(forKey: "uid")!
        plantNameLabel.text = plant?.plantName
        plantImageView.image = UIImage(data: (plant?.plantPhoto)!)
        //set the reference of firebase
        ref = Database.database().reference()
        retrieveAllRecords()
        
    }
    
    
    //MARK: - Firebase Data Retrieval
    //Reference: https://stackoverflow.com/questions/59744053/fill-an-array-through-a-nested-firebase-data-loop-swift
    
    func retrieveAllRecords(){
        let userRef = self.ref?.child(userID)
        let deviceRef = userRef?.child((plant?.macAddress)!)
        let dataRef = deviceRef?.child("data")
        //Order the records in ascending order
        dataRef?.queryOrdered(byChild: "Timestamp") .observe(.value, with: { (snapshot) in
            let childRecords = snapshot.children.allObjects as! [DataSnapshot]
            self.counter = 0
            //Loop through all records
            for record in childRecords.reversed(){
                //Read data from a single record
                self.readSingleRecord(node: record.key)
            }
        })
    }
    
    func readSingleRecord(node: String){
        let userRef = self.ref?.child(userID)
        let deviceRef = userRef?.child((plant?.macAddress)!)
        let dataRef = deviceRef?.child("data")
        let recordRef = dataRef?.child(node)
        recordRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            let lux = snapshot.childSnapshot(forPath: "Lux").value as? Double ?? 0
            let moisture = snapshot.childSnapshot(forPath: "Moisture").value as? Double ?? 0
        })
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "plantSettingSegue"{
            let destination = segue.destination as! PlantSettingViewController
            destination.plant = plant
            
            
        }
    }
    

}
