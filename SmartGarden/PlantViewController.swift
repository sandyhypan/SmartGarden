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
import Charts

class PlantViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var autoWateringSwitch: UISwitch!
    @IBOutlet weak var waterTankVolume: CosmosView!
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var plantImageView: UIImageView!
    var ref: DatabaseReference?
    var plant: Plant?
    var userID: String = ""
    var counter: Int = 0
    var luxRecords = [Double]()
    var moistureRecords = [Double]()
    var soilTempRecords = [Double]()
//    var waterTankVol: Double = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = UserDefaults.standard
        userID = userDefaults.string(forKey: "uid")!
        plantNameLabel.text = plant?.plantName
        plantImageView.image = UIImage(data: (plant?.plantPhoto)!)
        //Cosmos
        waterTankVolume.settings.updateOnTouch = false
        //set the reference of firebase
        ref = Database.database().reference()
        retrieveAllRecords()
        
        
        
        
    }
    
    @IBAction func plantSetting(_ sender: Any) {
        
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
            //Loop through all records from the most recent
            for record in childRecords.reversed(){
                //Read data from a single record
                self.readSingleRecord(node: record.key)
                //Get the most recent 20 records (#0 - #19)
                if self.counter == 20 {
                    break
                }
            }
            
        })
    }
    
    func readSingleRecord(node: String){
        let userRef = self.ref?.child(userID)
        let deviceRef = userRef?.child((plant?.macAddress)!)
        let dataRef = deviceRef?.child("data")
        let recordRef = dataRef?.child(node)
        recordRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            //Obtain the sensor readings and populate them into arrays
            let lux = snapshot.childSnapshot(forPath: "Lux").value as? Double ?? 0
            self.luxRecords.append(lux)
            let moisture = snapshot.childSnapshot(forPath: "Moisture").value as? Double ?? 0
            self.moistureRecords.append(moisture)
            let temp = snapshot.childSnapshot(forPath: "Temperature").value as? Double ?? 0
            self.soilTempRecords.append(temp)
            
            //Get only the most recent water tank level reading record
            if self.counter == 0 {
                let waterLevel = snapshot.childSnapshot(forPath: "Water level").value as? Double ?? 0
                let containerVolume = snapshot.childSnapshot(forPath: "Container Volume").value as? Double ?? 0
                
                //If the water tank sensor data is less than 0
                var waterVol: Double = 0
                if waterLevel <= 0{
                    waterVol = 0
                } else {
                    waterVol = waterLevel
                }
                
                if containerVolume <= 0{
                    self.waterTankVolume.rating = 0
                } else {
                    self.waterTankVolume.rating = waterVol/containerVolume
                }
                
            }
            self.counter += 1
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
