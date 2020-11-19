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
    
    var dismissKeyboardTapGesture: UIGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.setUpRightButton()
        confirmPasswordTextField.setUpRightButton()
        // Do any additional setup after loading the view.
        confirmPasswordTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Remove the notification observer
        NotificationCenter.default.removeObserver(self)
        
        super.viewWillDisappear(animated)
    }
    
    
    
    // MARK: - Dismiss keyboard and adjust View in response to keyboard notification
    
    @objc func dismissKeyboard(sender: AnyObject){
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    // Move the screen upward when the keyboard pop up
    @objc func keyboardWillShow(notification: NSNotification){
        // Register a gesture recognizer that will dismiss the keyboard if the user click on somewhere else
        if dismissKeyboardTapGesture == nil {
            dismissKeyboardTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            self.view.addGestureRecognizer(dismissKeyboardTapGesture!)
        }
        
        // Get the userinfo dictionary that consist of the information of the keyboard
        guard let userInfo = notification.userInfo else { return }
        
        // Get the size of the keyboard
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        
        // Minus view height with the keyboard height to move everything upwards
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= (keyboardFrame.height - 50)
        }
        
    }
    
    
    // Move the screen downward when the keyboard dismiss
    @objc func keyboardWillHide(notification: NSNotification){
        // Deregister the gesture recogniser when it is not needed
        if dismissKeyboardTapGesture != nil {
            self.view.removeGestureRecognizer(dismissKeyboardTapGesture!)
            dismissKeyboardTapGesture = nil
        }
        
        // Get the userinfo dictionary that consist of the information of the keyboard
        guard let userInfo = notification.userInfo else { return }
        
        // Get the size of the keyboard
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        
        // Add view height with the keyboard height to move everything upwards
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y += (keyboardFrame.height - 50)
        }
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



