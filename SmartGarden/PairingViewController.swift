//
//  PairingViewController.swift
//  SmartGarden
//
//  Created by England Kwok on 3/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//

import UIKit
import Network

class PairingViewController: UIViewController {

    @IBOutlet weak var ipUITextField: UITextField!
    
    var deviceUUID: String?
    var ipAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextButton(_ sender: Any) {
        let inputText = ipUITextField.text!
        
        // Check if the user input a valid ip address
        if inputText != ""{
            
            if let _ = IPv4Address(inputText){
                let url = URL(string: "http://\(inputText):5000/pair")

                // Get the UUID of the Pi
                let getUUIDTask = URLSession.shared.dataTask(with: url!) {(data, response, error) in
                    
                    
                    guard let data = data else{
                        // Request success but no data
                        return
                    }
                    
                    // Get the UUID of the sensor system
                    DispatchQueue.main.async {
                        self.deviceUUID = String(decoding: data, as: UTF8.self)
                        self.ipAddress = inputText
                        self.performSegue(withIdentifier: "addPlantSegue", sender: (Any).self)
                    }
                    
            }
                getUUIDTask.resume()
            }
        }	
    }
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addPlantSegue"{
            let destination = segue.destination as! AddPlantViewController
            destination.deviceUUID = deviceUUID
            destination.ipAddress = ipAddress
            
        }
    }
    

}

// MARK: -TextField Delegate
extension PairingViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
