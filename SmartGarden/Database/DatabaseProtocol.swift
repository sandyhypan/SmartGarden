//
//  DatabaseProtocol.swift
//  SmartGarden
//
//  Created by England Kwok on 13/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType{
    case plant
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType{get set}
    func onPlantChange(change: DatabaseChange, plants: [Plant])
}

protocol DatabaseProtocol: AnyObject {
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func deletePlant(plant: Plant)
    func addPlant(plantName: String, ipAddress: String, macAddress: String, plantPhoto: Data?) -> Plant
    func cleanUp()
    func updatePlant(plant: Plant, plantName: String, plantImage: Data)
    
    
}
