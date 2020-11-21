//
//  Device.swift
//  SmartGarden
//
//  Created by Adrian Yip on 21/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//

import Foundation

class Device: NSObject{
    
    let macAddress: String!
    let plantName: String!
    
    init(macAddress: String, plantName: String) {
        self.macAddress = macAddress
        self.plantName = plantName
    }
}
