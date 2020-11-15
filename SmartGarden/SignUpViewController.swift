//
//  SignUpViewController.swift
//  SmartGarden
//
//  Created by England Kwok on 3/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.

import UIKit
import Firebase


class SignUpViewController: UIViewController {

    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        confirmPasswordTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self
    }
    
    @IBAction func signUp(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" && confirmPasswordTextField.text != ""{
            // Check if the password and the confirm password are the same
            if passwordTextField.text == confirmPasswordTextField.text{
                // Check if the format of email is valid
                let email = emailTextField.text!
                
                // Valid email format
                if Validator.isValidEmail(email: email){
                    let password = passwordTextField.text!
                    
                    // Create an account
                    Auth.auth().createUser(withEmail: email, password: password, completion: {(user, error) in
                        // Check if the user is successfully created
                        if let _ = user{
                            // Back to home page
                            self.performSegue(withIdentifier: "homeSegue", sender: self)
                        } else {
                            // Check error and show message
                            let error = error?.localizedDescription
                            DisplayMessages.displayAlert(title: "An error occured", message: error ?? "An unknown error occured. Please try again later.")
                        }
                    })
                }else{
                    // Invalid email format
                    DisplayMessages.displayAlert(title: "Invalid email", message: "Please check the format of the email address.")
                }
            }else{
                // Password and confirm password not matched
                DisplayMessages.displayAlert(title: "Password mismatch.", message: "Please double check your password.")
            }
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
extension SignUpViewController	: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
