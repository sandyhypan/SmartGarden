//
//  AddPlantViewController.swift
//  SmartGarden
//
//  Created by England Kwok on 3/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plantNameTextfield.delegate = self
        waterTankVolumeTextField.delegate = self
        moistureLevelTextField.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
//        guard ipAddress != nil, deviceUUID != nil else {
//            print("ipAddress or deviceUUID is missing!")
//            return
//        }
    }
    
    //MARK: - Image picker
    
    @IBAction func selectImage(_ sender: Any) {
     let vc = UIImagePickerController()
               //        vc.delegate = self
               vc.sourceType = .photoLibrary
               vc.delegate = self
               vc.allowsEditing = true
               present(vc, animated: true)
               
           }
           
           func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
               
               if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage{
                   plantImage.image = image
                   if let img = plantImage.image?.pngData{
                       plantImageData = img()
                       
                   }
                   
                   if let img = plantImage.image?.jpegData{
                    plantImageData = img(0.8)
                   }
                   
               }
               picker.dismiss(animated: true, completion: nil)
           }
           
           func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
               picker.dismiss(animated: true, completion: nil)
           }
    
    //MARK: - save plant
    @IBAction func savePlant(_ sender: Any) {
        
        if plantNameTextfield.text != "" && waterTankVolumeTextField.text != "" && moistureLevelTextField.text != "" &&  plantImage != nil{
            
            print("line 70 ------------------- add plant")
            
            let plantName = plantNameTextfield.text!
            let waterTankVol = Double(waterTankVolumeTextField.text!)
            let moisture = Double(moistureLevelTextField.text!)
            
            
            //Add plant to core data
            let _ = databaseController?.addPlant(plantName: plantName, ipAddress: ipAddress!, macAddress: deviceUUID!, plantPhoto: plantImageData)
            
            //Post user preferences to Pi
            
            //moisture level http call
            let moistureUrlString = "http://\(ipAddress!):5000/setMoisture/\(moistureLevelTextField.text!)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            let moistureURL = URL(string: moistureUrlString!)
            
            let dataTask = URLSession.shared.dataTask(with: moistureURL!) {(data, response, error) in
                
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "savePlantSegue", sender: self)
                }
                
            }
            dataTask.resume()
            
            
        } else{
            DisplayMessages.displayAlert(title: "Error", message: "All fields must be filled.")
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
