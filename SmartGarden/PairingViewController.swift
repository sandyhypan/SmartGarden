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
    var uid: String?
    var ipAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextButton(_ sender: Any) {
        let inputText = ipUITextField.text!

        // Check if the user input a valid ip address
        if inputText != ""{
            // ref https://stackoverflow.com/questions/24482958/validate-if-a-string-in-nstextfield-is-a-valid-ip-address-or-domain-name
            // For validating format of IPv4 address
            var sin = sockaddr_in()
            if inputText.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1{
                let url = URL(string: "http://\(inputText):5000/pair")

                var request = URLRequest(url: url!)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                let body = ["uid": Authenticate.getUID()]
                let bodyData = try? JSONSerialization.data(withJSONObject: body, options: [])
                request.httpBody = bodyData

                // Get the UUID of the Pi
                // Set timeout to 5 sec
                let sessionConfig = URLSessionConfiguration.default
                sessionConfig.timeoutIntervalForRequest = 6.0
                let session = URLSession(configuration: sessionConfig)
                let getUUIDTask = session.dataTask(with: request) {(data, response, error) in

                    guard let data = data else{
                        DispatchQueue.main.async {
                            DisplayMessages.displayAlert(title: "Pairing failed.", message: "Please make sure the device is at the same network and the IP address is correct.")
                        }
                        return
                    }

                    // Get the UUID of the sensor system
                    DispatchQueue.main.async {
                        self.ipAddress = inputText
                        self.deviceUUID = String(decoding: data, as: UTF8.self)
                        self.performSegue(withIdentifier: "addPlantSegue", sender: (Any).self)
                    }
            }
                getUUIDTask.resume()
            } else {
                DisplayMessages.displayAlert(title: "Invalid IP format", message: "Please double check the format of the IP address.")
            }
        }
        self.performSegue(withIdentifier: "addPlantSegue", sender: self)
    }
    

    
    
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addPlantSegue"{
            let destination = segue.destination as! AddPlantViewController
            destination.deviceUUID = deviceUUID
            destination.uid = uid
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
