//
//  SignInViewController.swift
//  SmartGarden
//
//  Created by England Kwok on 3/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//

import UIKit
//import FirebaseDatabase
import Firebase

class SignInViewController: UIViewController {
    @IBOutlet weak var dummyLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    weak var loginHandle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        loginHandle = Auth.auth().addStateDidChangeListener{(auth, user) in
//
//
//        }
//    }
    
    @IBAction func signIn(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != ""{
            let email = emailTextField.text!
            let password = passwordTextField.text!
            
            // Check if the email is in a valid format
            // The input format is valid
            if Validator.isValidEmail(email: email){
                Auth.auth().signIn(withEmail: email, password: password, completion: { (authResult, error) in
                    guard let user = authResult?.user, error == nil else {
                        DisplayMessages.displayAlert(title: "An error occured.", message: error?.localizedDescription ?? "An unknown error occured. Please try again later.")
                        return	
                    }
                    
                    // Store user auth data after login
                    UserDefaults.standard.set(user.uid, forKey: "uid")
                    self.performSegue(withIdentifier: "signInSegue", sender: self)
                })
            } else {
                DisplayMessages.displayAlert(title: "Invalid email.", message: "Invalid email format. Please double check and try agian.")
            }
        } else {
            DisplayMessages.displayAlert(title: "Empty credentials.", message: "Please provide valid email and password.")
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - TextField delegate
extension SignInViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

