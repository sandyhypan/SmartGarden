//
//  User.swift
//  SmartGarden
//
//  Created by Adrian Yip on 15/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//

import Foundation

class User: NSObject{
    var uid: String
    var email: String?
    
    init(uid:String, email:String?){
        self.uid = uid
        self.email = email
    }
}
