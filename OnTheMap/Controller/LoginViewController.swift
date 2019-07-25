//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Ahmed Afifi on 7/18/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.borderStyle = .roundedRect
        passwordTextField.borderStyle = .roundedRect
        loginButton.layer.cornerRadius = 5
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShow))
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillHide))
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    @objc private func addLocation(_ sender: Any){
        let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddLocationNavigationController") as! UINavigationController
        present(navController, animated: true, completion: nil)
    }
    
    private func fieldsChecker(){
        if (emailTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)!  {
            let alert = UIAlertController(title: "Fill the auth info", message: "Please fill both email and password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                return
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        fieldsChecker()
        ParseAPI.shared.login(emailTextField.text!, passwordTextField.text!) {(successful, error) in
            DispatchQueue.main.async {
                // for any error not expeceted
                if let error = error {
                    print(error.localizedDescription)
                    let errorAlert = UIAlertController(title: "Error", message: "There is error", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                        return
                    }))
                    self.present(errorAlert, animated: true, completion: nil)
                }
                
                // for invalid email or password
                if !successful {
                    let invalidAccessAlert = UIAlertController(title: "Invalid Access", message: "Invalid email or password", preferredStyle: .alert)
                    invalidAccessAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                        return
                    }))
                    self.present(invalidAccessAlert, animated: true, completion: nil)
                } else {
                    
                    // move to next storyboard
                    let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                    self.present(mapVC, animated: true, completion: nil)
                    
                    //self.navigationController!.pushViewController(mapVC, animated: true)
                    //self.present(mapVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        guard let url = URL(string: "https://www.udacity.com/account/auth#!/signup") else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
}
    
extension LoginViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if keyboardHeight(notification) > 400 {
            view.frame.origin.y = -keyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
}

    
private extension LoginViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

