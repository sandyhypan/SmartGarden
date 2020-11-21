//
//  CoreDataController.swift
//  SmartGarden
//
//  Created by England Kwok on 13/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController: NSObject, NSFetchedResultsControllerDelegate, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer : NSPersistentContainer
    
    var allPlantsFetchedResultsController: NSFetchedResultsController<Plant>?
    
    override init() {
        //load core data stack
        persistentContainer = NSPersistentContainer(name: "PlantModel")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error{
                fatalError("Failed to load Core Data Stack: \(error)")
            }
        }
        
        super.init()
    }
    
    func saveContext(){
        if persistentContainer.viewContext.hasChanges{
            do{
                try persistentContainer.viewContext.save()
            } catch{
                fatalError("Failed to save to Core Data: \(error)")
            }
        }
    }
    
    //MARK: - Database Protocol Functions
    
    func cleanUp(){
        saveContext()
    }
    
    func deletePlant(plant: Plant) {
        persistentContainer.viewContext.delete(plant)
    }
    
    func addPlant(plantName: String, ipAddress: String, macAddress: String, plantPhoto: Data?) -> Plant {
        let plant = NSEntityDescription.insertNewObject(forEntityName: "Plant", into: persistentContainer.viewContext) as! Plant
        plant.plantName = plantName
        plant.ipAddress = ipAddress
        plant.macAddress = macAddress
        plant.plantPhoto = plantPhoto
        
        return plant
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .plant{
            listener.onPlantChange(change: .update, plants: fetchAllPlants())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func updatePlant(plant: Plant, plantName: String, plantImage: Data) {
        plant.setValue(plantName, forKey: "plantName")
        plant.setValue(plantImage, forKey: "plantPhoto")
    }
     
    
    
    //MARK: - fetch results controller protocol function
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allPlantsFetchedResultsController{
            listeners.invoke { (listener) in
                if listener.listenerType == .plant{
                    listener.onPlantChange(change: .update, plants: fetchAllPlants())
                }
            }
        }
    }
    
    func fetchAllPlants() -> [Plant]{
        //if results controller is not currently initialized
        if allPlantsFetchedResultsController == nil{
            let fetchRequest : NSFetchRequest<Plant> = Plant.fetchRequest()
            //sort by name
            let nameSortDescriptor = NSSortDescriptor(key:"plantName", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            
            //initialize results controller
            allPlantsFetchedResultsController = NSFetchedResultsController<Plant>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            //Set this class to be the results delegate
            allPlantsFetchedResultsController?.delegate = self
            
            do{
                try allPlantsFetchedResultsController?.performFetch()
            }catch{
                print("Failed to Fetch Request: \(error)")
            }
        }
        
        var plants = [Plant]()
        if allPlantsFetchedResultsController?.fetchedObjects != nil{
            plants = (allPlantsFetchedResultsController?.fetchedObjects)!
        }
        
        return plants
    }
    
}
