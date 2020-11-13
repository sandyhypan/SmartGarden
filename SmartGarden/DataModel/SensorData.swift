//
//  SensorData.swift
//  SmartGarden
//
//  Created by England Kwok on 13/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//

import Foundation


class SensorData: NSObject, Codable {
    var lux: Double
    var moisture: Double
    var moistureThreshold: Double
    var probingPeriod: Double
    var temperature: Double
    var timeStamp: String
    var waterLevel: Double
    var watered: Bool
    
    enum CodingKeys: String, CodingKey{
        
        case lux = "Lux"
        case moisture = "Moisture"
        case moistureThreshold = "Moisture threshold"
        case probingPeriod = "Probing period"
        case temperature = "Temperature"
        case timeStamp = "Timestamp"
        case waterLevel = "Water level"
        case watered = "Watered"
    }

    
}

