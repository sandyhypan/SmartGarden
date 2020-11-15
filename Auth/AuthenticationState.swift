//
//  AuthenticationState.swift
//  SmartGarden
//
//  Created by Adrian Yip on 15/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//

import Foundation
import Firebase

class AuthenticationState: NSObject, ObservableObject{
    
    @Published var user: User?
    @Published var error: NSError?
    
    static let sharedState = AuthenticationState()
    
    var handle: AuthStateDidChangeListenerHandle?
    
    func listen(){
        handle = Auth.auth().addStateDidChangeListener{(auth, user) in
            if let user = user {
                self.user = User(uid: user.uid, email: user.email)
            }
        }
    }
}
