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
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var dismissKeyboardTapGesture: UIGestureRecognizer?
    
    weak var loginHandle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.setUpRightButton()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Get notification for keyboard appearing and closing
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

/*Reference: https://stackoverflow.com/questions/37873119/how-to-toggle-a-uitextfield-secure-text-entry-hide-password-in-swift
 */

extension UITextField{
    fileprivate func toggleImage(_ rightButton: UIButton){
        if(isSecureTextEntry){
            rightButton.setImage(UIImage(named: "invisible"), for: .normal)
        } else {
            rightButton.setImage(UIImage(named: "visible"), for: .normal)
        }
        
    }
    
    func setUpRightButton(){
        let rightButton = UIButton(type: .custom)
        toggleImage(rightButton)
        rightButton.frame = CGRect(x: CGFloat(self.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        rightButton.addTarget(self, action: #selector(self.toggleVisibility), for: .touchUpInside)
        self.rightView = rightButton
        self.rightViewMode = .always
        
    }
    
    @IBAction func toggleVisibility(_ sender: Any){
        self.isSecureTextEntry.toggle()
        toggleImage(sender as! UIButton)
    }
    
}

