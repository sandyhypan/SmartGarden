//
//  FirebaseController.swift
//  SmartGarden
//
//  Created by Adrian Yip on 21/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//

import Foundation
import Firebase

class FirebaseController: NSObject {
    
    static func getUserDevices(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let databaseController = appDelegate.databaseController
        
        let ref = Database.database().reference()
        
        let userID = Auth.auth().currentUser?.uid
        ref.child(userID!).observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children{
                var snapshot = child as! DataSnapshot
                let macAddress = snapshot.key
                snapshot = snapshot.childSnapshot(forPath: "plant_info")
                let plantName = snapshot.childSnapshot(forPath: "plant_name").value as! String
                let ip = snapshot.childSnapshot(forPath: "ip").value as! String
                
                let _ = databaseController?.addPlant(plantName: plantName, ipAddress: ip, macAddress: macAddress, plantPhoto: UIImage(named: "default_plant")?.pngData())
            }
            
    
        })
        
    }
    
}
