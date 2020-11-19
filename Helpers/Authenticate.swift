//
//  Authenticate.swift
//  SmartGarden
//
//  Created by Adrian Yip on 20/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//

import Foundation
import Firebase

class Authenticate: NSObject{
    
    static func getUID() -> String{
        let user = Auth.auth().currentUser
        
        return user!.uid
    }
}
