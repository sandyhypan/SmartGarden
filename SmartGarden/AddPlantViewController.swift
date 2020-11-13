//
//  AddPlantViewController.swift
//  SmartGarden
//
//  Created by England Kwok on 3/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//

import UIKit

class AddPlantViewController: UIViewController {
    @IBOutlet weak var plantNameTextfield: UITextField!
    
    @IBOutlet weak var waterTankVolumeTextField: UITextField!
    
    @IBOutlet weak var moistureLevelTextField: UITextField!
    
    @IBOutlet weak var lightLevelTextField: UITextField!
    
    @IBOutlet weak var soilTempTextField: UITextField!
    
    @IBOutlet weak var plantImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func selectImage(_ sender: Any) {
    }
    
    @IBAction func savePlant(_ sender: Any) {
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
