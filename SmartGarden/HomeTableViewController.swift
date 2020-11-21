//
//  HomeTableViewController.swift
//  SmartGarden
//
//  Created by England Kwok on 3/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomeTableViewController: UITableViewController, DatabaseListener {
    
    let SECTION_PLANT = 0
    let SECTION_INTO = 1
    let CELL_PLANT = "plantCell"
    let CELL_INFO = "infoCell"
    
    
    var currentPlants : [Plant] = []
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .plant
    var selectedPlant: Plant?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        if databaseController?.getAllPlants().count == 0{
            FirebaseController.getUserDevices()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    @IBAction func logout(_ sender: Any) {
        // Clear user data
        do {
            // Clear firebase auth data
            try Auth.auth().signOut()
            // Sync Firebase
            
            // Clear core data
            databaseController?.deleteAllPlants()
            
        } catch {
            DisplayMessages.displayAlert(title: "Logout failed", message: "An unknown error occured. Please try again later")
        }
        
        // Go back to login screen
        let loginViewController = storyboard?.instantiateViewController(withIdentifier: "login") as! SignInViewController
        let navigationController = UINavigationController(rootViewController: loginViewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    
    
    
    // MARK: - Database Listener
    
    func onPlantChange(change: DatabaseChange, plants: [Plant]) {
        currentPlants = plants
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_PLANT:
            return currentPlants.count
        case SECTION_INTO:
            return 1
        default:
            return 0
        }
    }

    // populate cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == SECTION_PLANT{
            let plantCell = tableView.dequeueReusableCell(withIdentifier: "plantCell", for: indexPath)
            let plant = currentPlants[indexPath.row]
            plantCell.textLabel?.text = plant.plantName
            plantCell.imageView?.image = UIImage(data: plant.plantPhoto!)

            return plantCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
        
        cell.textLabel?.textColor = .secondaryLabel
        cell.selectionStyle = .none
        if currentPlants.count > 0 {
            cell.textLabel?.text = "\(currentPlants.count) plants saved."
        } else {
            cell.textLabel?.text = "Click + to add plant."
        }
        
        return cell
    }
    
    // select cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlant = currentPlants[indexPath.row]
        performSegue(withIdentifier: "plantSegue", sender: self)
    }
    
   
    // delete plant record
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let plant = currentPlants[indexPath.row]
            self.databaseController?.deletePlant(plant: plant)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "plantSegue"{
            let destination = segue.destination as? PlantViewController
            destination?.plant = selectedPlant
        }
    }
 
    

}
