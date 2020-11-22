//
//  Validator.swift
//  SmartGarden
//
//  Created by Adrian Yip on 15/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//
//  ref: https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift

import Foundation

class Validator{
    
    static func isValidEmail(email: String) -> Bool{
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: email)
    }
}
