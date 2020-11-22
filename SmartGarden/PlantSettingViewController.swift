//
//  PlantSettingViewController.swift
//  SmartGarden
//
//  Created by England Kwok on 3/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PlantSettingViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @IBOutlet weak var plantNameTextField: UITextField!
    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var moistureLevelTextField: UITextField!
    @IBOutlet weak var waterTankVolumeTextField: UITextField!
    weak var databaseController: DatabaseProtocol?
    var plantImageData: Data?
    var uid: String?
    var ref: DatabaseReference?
    var plant: Plant?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plantNameTextField.delegate = self
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
    
    
    
    
    
    @IBAction func savePlant(_ sender: Any) {
        if plantNameTextField.text != "" && waterTankVolumeTextField.text != "" && moistureLevelTextField.text != "" &&  plantImage != nil{
            
            let plantName = plantNameTextField.text!
            let ipAddress = plant?.ipAddress
            let deviceUUID = plant?.macAddress
            
            if Double(waterTankVolumeTextField.text!) != nil && Double(moistureLevelTextField.text!) != nil{
                
                if Double(moistureLevelTextField.text!)! > 0 && Double(moistureLevelTextField.text!)! < 100{
                    //image
                    if let img = plantImage.image?.pngData{
                        plantImageData = img()
                    }
                    if let img = plantImage.image?.jpegData{
                        plantImageData = img(0.8)
                    }
                    //Modify plant in core data
                    databaseController?.updatePlant(plant: plant!, plantName: plantName, plantImage: plantImageData!)
                    
                    //Save name to firebase
                    ref?.child("\(uid!)/\(deviceUUID!)/plant_info/plant_name").setValue(plantName)
                    
                    
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
                    
                    self.performSegue(withIdentifier: "saveSettingSegue", sender: self)
                    
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveSettingSegue"{
            let destination = segue.destination as! PlantViewController
            destination.plant = plant
            
            
        }
    }
 
    

}

//MARK: -Text Field Delegates
extension PlantSettingViewController    : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//Reference: https://stackoverflow.com/questions/37309793/how-can-you-check-if-a-string-is-a-valid-double-in-swift
extension Double {
    init?(format:String) {
        guard let
            standardDouble = Double(format),
            let firstChar: Character? = format.first,
            let lastChar: Character? = format.last, firstChar != "." && lastChar != "."
            else { return nil }
        self = standardDouble
    }
}

