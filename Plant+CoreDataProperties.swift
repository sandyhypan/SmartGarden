//
//  Plant+CoreDataProperties.swift
//  SmartGarden
//
//  Created by England Kwok on 13/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//
//

import Foundation
import CoreData


extension Plant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Plant> {
        return NSFetchRequest<Plant>(entityName: "Plant")
    }

    @NSManaged public var plantName: String?
    @NSManaged public var ipAddress: String?
    @NSManaged public var macAddress: String?
    @NSManaged public var plantPhoto: Data?

}
