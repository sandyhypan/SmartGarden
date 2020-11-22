//
//  AddPlantViewController.swift
//  SmartGarden
//
//  Created by England Kwok on 3/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddPlantViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var plantNameTextfield: UITextField!
    @IBOutlet weak var waterTankVolumeTextField: UITextField!
    @IBOutlet weak var moistureLevelTextField: UITextField!
    @IBOutlet weak var plantImage: UIImageView!
    weak var databaseController: DatabaseProtocol?
    var plantImageData: Data?
    var deviceUUID: String?
    var ipAddress: String?
    var uid: String?
    var ref: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plantNameTextfield.delegate = self
        waterTankVolumeTextField.delegate = self
        moistureLevelTextField.delegate = self
        //userDefaults
        let userDefaults = UserDefaults.standard
        uid = userDefaults.string(forKey: "uid")!
        //DB reference
        ref = Database.database().reference()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        //hints
        waterTankVolumeTextField.placeholder = "In millilitre (mL)"
        moistureLevelTextField.placeholder = "Between 0 to 100"
    }
    
    //MARK: - Image picker
    //references:https://www.youtube.com/watch?v=HqxeyS961Uk&ab_channel=SergeyKargopolov
    //https://www.youtube.com/watch?v=yggOGEzueFk&ab_channel=iOSAcademy
    
    @IBAction func selectImage(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage{
            plantImage.image = image
            //            if let img = plantImage.image?.pngData{
            //                plantImageData = img()
            //            }
            //            if let img = plantImage.image?.jpegData{
            //                plantImageData = img(0.8)
            //            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - save plant
    @IBAction func savePlant(_ sender: Any) {
        
        if plantNameTextfield.text != "" && waterTankVolumeTextField.text != "" && moistureLevelTextField.text != "" &&  plantImage != nil{
            let plantName = plantNameTextfield.text!
            
            
            if Double(waterTankVolumeTextField.text!) != nil && Double(moistureLevelTextField.text!) != nil{
                
                if Double(moistureLevelTextField.text!)! > 0 && Double(moistureLevelTextField.text!)! < 100{
                    //image
                    if let img = plantImage.image?.pngData{
                        plantImageData = img()
                    }
                    if let img = plantImage.image?.jpegData{
                        plantImageData = img(0.8)
                    }
                    
                    //Add plant to core data
                    let _ = databaseController?.addPlant(plantName: plantName, ipAddress: ipAddress!, macAddress: deviceUUID!, plantPhoto: plantImageData)
                    
                    //Save to firebase
                    ref?.child("\(uid!)/\(deviceUUID!)/plant_info/plant_name").setValue(plantName)
                    ref?.child("\(uid!)/\(deviceUUID!)/plant_info/ip").setValue(ipAddress)
                    ref?.child("\(uid!)/\(deviceUUID!)/auto_water").setValue(false)
                    
                    
                    //Post user preferences to Pi
                    //moisture level http call
                    let moistureUrlString = "http://\(ipAddress!):5000/setMoisture/\(moistureLevelTextField.text!)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    let moistureURL = URL(string: moistureUrlString!)
                    let dataTask = URLSession.shared.dataTask(with: moistureURL!) {(data, response, error) in

                        if let error = error{
                            print(error.localizedDescription)
                            return
                        }

                    }

                    dataTask.resume()
                    
                    //water tank volume http call
                    let containerUrlString = "http://\(ipAddress!):5000/setContainerVolumn/\(waterTankVolumeTextField.text!)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    let containerURL = URL(string: containerUrlString!)
                    let dataTask2 = URLSession.shared.dataTask(with: containerURL!) {(data, response, error) in
                        if let error = error{
                            print(error.localizedDescription)
                            return
                        }
                    }
                    dataTask2.resume()

                    self.performSegue(withIdentifier: "savePlantSegue", sender: self)
                    
                } else {
                    DisplayMessages.displayAlert(title: "Error", message: "Moisture level should be between 0 to 100")
                }
        } else {
            DisplayMessages.displayAlert(title: "Error", message: "Please input correct format for water tank volume or moisture level")
            }
        
    } else{
    DisplayMessages.displayAlert(title: "Error", message: "All fields must be filled")
    }
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
//MARK: -Text Field Delegates
extension AddPlantViewController    : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



