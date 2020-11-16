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
    var ipAddress: String?
    var uid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plantNameTextfield.delegate = self
        waterTankVolumeTextField.delegate = self
        moistureLevelTextField.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
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
        
        if plantNameTextfield.text != "" && waterTankVolumeTextField.text != "" && moistureLevelTextField.text != "" &&  plantImage != nil && uid != nil && ipAddress != nil{
            
            let plantName = plantNameTextfield.text!
            let waterTankVol = Double(waterTankVolumeTextField.text!)
            let moisture = Double(moistureLevelTextField.text!)
            
            
            //Add plant to core data
            let _ = databaseController?.addPlant(plantName: plantName, ipAddress: ipAddress!, macAddress: uid!, plantPhoto: plantImageData)
            
            //Post user preferences to Pi
            
            let moistureEndpoint = "http://\(ipAddress)/setMoisture/\(moisture)"
            guard let moistureURL = URL(string: moistureEndpoint) else{
                return
            }
            
            let dataTask = URLSession.shared.dataTask(with: moistureURL) {(data, response, error) in
                
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
            }
            dataTask.resume()
            
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
