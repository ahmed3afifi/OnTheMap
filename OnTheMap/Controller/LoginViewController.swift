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
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    let device = UIDevice.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //update ui
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.borderStyle = .roundedRect
        passwordTextField.borderStyle = .roundedRect
        loginButton.layer.cornerRadius = 5
        
        //
        subscribeToNotification()
        
        //animate
         activityView.stopAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        device.beginGeneratingDeviceOrientationNotifications()
        subscribeToNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        device.endGeneratingDeviceOrientationNotifications()
        unsubscribeFromAllNotifications()
    }
    
    // MARK: WHEN LOGIN BUTTON PRESSED
    @IBAction func loginPressed(_ sender: Any) {
        
        //validate email and pass
        let username: String = emailTextField.text!
        let password : String = passwordTextField.text!
        if (username.isEmpty) || (password.isEmpty)  {
            let alert = UIAlertController(title: "Login Failed", message: "Please fill both email and password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: {_ in
                self.present(alert, animated: true, completion: nil)
                return
            }))
            return
        }
        
        //progress
        activityView.startAnimating()
   
        
        UdacityAPI.sharedInstance().login(email: username, password: password, completionHandlerForLogin: { (success, sessionID, error) in
            if success {
                UdacityAPI.sharedInstance().getUser()
                DispatchQueue.main.async {
                    self.completeLogin()
                }
            } else {
                DispatchQueue.main.async {
                    self.activityView.stopAnimating()
                    let alert = UIAlertController(title: "Login Failed", message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                
            }
        })
        
    }
    
    private func completeLogin() {
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "TabBarController")
        present(controller, animated: true, completion: nil)
        self.activityView.stopAnimating()
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
    
    func subscribeToNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

